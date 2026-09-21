import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/env_config.dart';
import '../../core/errors/app_exception.dart';
import '../models/ai_message_model.dart';

/// Separate Dio instance — different host/auth scheme than VCare's
/// ApiClient (Google API key header, not Bearer JWT). Never logs the
/// key itself.
///
/// The key comes from `--dart-define=GEMINI_API_KEY=...` via
/// [EnvConfig]; [apiKey] exists only so tests can exercise the HTTP
/// path with a dummy value — production always uses the dart-define.
class GeminiRemoteDataSource {
  GeminiRemoteDataSource({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: connectTimeout)),
        _apiKey = apiKey ?? EnvConfig.geminiApiKey;

  final Dio _dio;
  final String _apiKey;

  /// Time to establish the connection (applied on the default Dio).
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Time to upload the request body / wait for the full reply. Applied
  /// per request so it also holds for an injected Dio. Generation can
  /// legitimately take several seconds, hence 30s rather than the API
  /// client's 15s; a hang beyond that becomes a normal failure instead
  /// of an endless "Typing…".
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent';

  static const _systemPrompt =
      'You are the VCare AI Assistant inside a doctor appointment booking app. '
      'Help with general health information, explaining medical terms simply, '
      'suggesting which specialty may be relevant, and explaining how to use VCare '
      '(searching doctors, booking appointments, viewing appointments). '
      'You are NOT a doctor and must never claim to be one or give a definitive diagnosis. '
      'For potentially serious symptoms, recommend the user consult a qualified healthcare '
      'professional or seek urgent care. Keep answers concise and friendly.';

  bool get _hasKey => _apiKey.isNotEmpty;

  Future<String> sendMessage(List<AIMessageModel> history) async {
    debugPrint('[GEMINI] API key present: $_hasKey');
    if (!_hasKey) {
      throw const AppException(
          'AI Assistant is not configured. Missing API key.',
          code: AppErrorCode.aiNotConfigured);
    }
    debugPrint('[GEMINI] Request → generateContent (${history.length} turns)');
    try {
      final response = await _dio.post(
        _endpoint,
        options: Options(
          headers: {
            'X-goog-api-key': _apiKey,
            'Content-Type': 'application/json',
          },
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
        ),
        data: {
          'system_instruction': {
            'parts': [
              {'text': _systemPrompt}
            ]
          },
          'contents': history.map((m) => m.toGeminiPart()).toList(),
        },
      );
      debugPrint('[GEMINI] Response status: ${response.statusCode}');
      return parseGeneratedText(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Extracts the assistant text from a `generateContent` body.
  ///
  /// Defensive on purpose: every field is type-checked before use, so a
  /// surprising shape (a candidate that is not an object, a missing
  /// `content`, non-text parts…) becomes a controlled [AppException]
  /// rather than a crash — and never a silently empty "success".
  /// Recognised outcomes:
  /// - prompt blocked (`promptFeedback.blockReason`) or a candidate
  ///   stopped for `SAFETY`/`RECITATION` → [AppErrorCode.aiBlocked]
  /// - no candidates / no text → [AppErrorCode.aiEmptyResponse]
  @visibleForTesting
  static String parseGeneratedText(dynamic data) {
    if (data is! Map<String, dynamic>) throw _unexpected();

    final feedback = data['promptFeedback'];
    if (feedback is Map && feedback['blockReason'] != null) throw _blocked();

    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) throw _empty();

    final first = candidates.first;
    if (first is! Map) throw _unexpected();

    final finishReason = first['finishReason'];
    if (finishReason is String &&
        const {'SAFETY', 'RECITATION', 'BLOCKLIST', 'PROHIBITED_CONTENT'}
            .contains(finishReason.toUpperCase())) {
      throw _blocked();
    }

    final content = first['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) throw _empty();

    final text = parts
        .map((p) => p is Map && p['text'] is String ? p['text'] as String : '')
        .join();
    if (text.trim().isEmpty) throw _empty();
    return text;
  }

  static AppException _unexpected() => const AppException(
      'The assistant returned an unexpected response. Please try again.',
      code: AppErrorCode.aiEmptyResponse);

  static AppException _blocked() => const AppException(
      'The assistant could not answer that request. Please rephrase and try again.',
      code: AppErrorCode.aiBlocked);

  static AppException _empty() => const AppException(
      'The assistant did not return a response. Please try again.',
      code: AppErrorCode.aiEmptyResponse);

  /// Every transport/HTTP failure becomes an [AppException] with a
  /// user-safe message. Google's own error text is logged (it never
  /// contains our key) but not shown, so internal API details such as
  /// model or quota names never reach the UI.
  AppException _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final serverMessage = _extractGeminiErrorMessage(e.response?.data);
    debugPrint('[GEMINI] Error type:${e.type.name} status:$status '
        'message:${serverMessage ?? e.message}');

    // Plain if-chain (not an exhaustive switch) so a new
    // DioExceptionType in a future dio release falls through to the
    // status-code mapping instead of breaking compilation.
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppException(
          'The assistant took too long to respond. Please try again.',
          code: AppErrorCode.aiTimeout);
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    if (e.type == DioExceptionType.cancel) {
      return const AppException('Request was cancelled.',
          code: AppErrorCode.cancelled);
    }

    if (status == 400) {
      return const AppException('The AI request was invalid. Please try again.',
          code: AppErrorCode.aiInvalidRequest);
    }
    if (status == 401 || status == 403) {
      return const AppException(
          'AI Assistant is unavailable right now (invalid key).',
          code: AppErrorCode.aiInvalidKey);
    }
    if (status == 429) {
      return const AppException(
          'Too many requests. Please wait a moment and try again.',
          code: AppErrorCode.aiRateLimited);
    }
    if (status != null && status >= 500) {
      return const AppException('AI service error. Please try again shortly.',
          code: AppErrorCode.aiServiceError);
    }
    return const AppException('Something went wrong. Please try again.');
  }

  /// Gemini's error body shape:
  /// { "error": { "message": "...", "status": "INVALID_ARGUMENT" } }
  String? _extractGeminiErrorMessage(dynamic data) {
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final msg = data['error']['message'];
      if (msg is String) return msg;
    }
    return null;
  }
}
