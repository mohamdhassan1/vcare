import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/env_config.dart';
import '../../core/errors/app_exception.dart';
import '../models/ai_message_model.dart';

/// Separate Dio instance — different host/auth scheme than VCare's
/// ApiClient (Google API key header, not Bearer JWT). Never logs the
/// key itself.
class GeminiRemoteDataSource {
  GeminiRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

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

  Future<String> sendMessage(List<AIMessageModel> history) async {
    debugPrint('[GEMINI] API key present: ${EnvConfig.hasGeminiKey}');
    if (!EnvConfig.hasGeminiKey) {
      throw const AppException(
          'AI Assistant is not configured. Missing API key.');
    }
    debugPrint('[GEMINI] Request → generateContent (${history.length} turns)');
    try {
      final response = await _dio.post(
        _endpoint,
        options: Options(headers: {
          'X-goog-api-key': EnvConfig.geminiApiKey,
          'Content-Type': 'application/json',
        }),
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

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException(
            'The assistant returned an unexpected response. Please try again.');
      }

      final blockReason = data['promptFeedback']?['blockReason'];
      if (blockReason != null) {
        throw const AppException(
            'The assistant could not answer that request. Please rephrase and try again.');
      }

      final candidates = data['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        throw const AppException(
            'The assistant did not return a response. Please try again.');
      }

      final parts = candidates[0]?['content']?['parts'];
      if (parts is! List || parts.isEmpty) {
        throw const AppException(
            'The assistant returned an empty response. Please try again.');
      }

      final text = parts
          .map(
              (p) => p is Map && p['text'] is String ? p['text'] as String : '')
          .join();
      if (text.trim().isEmpty) {
        throw const AppException(
            'The assistant returned an empty response. Please try again.');
      }
      return text;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Sanitized: Gemini's own error body never contains our API key
      // (the key is sent as a request header, never echoed back in
      // any response body), so this is safe to log in full.
      debugPrint('[GEMINI] Error status:$status body:${e.response?.data}');
      if (status == 400) {
        throw AppException(_extractGeminiErrorMessage(e.response?.data) ??
            'The AI request was invalid. Please try again.');
      }
      if (status == 401 || status == 403) {
        throw const AppException(
            'AI Assistant is unavailable right now (invalid key).');
      }
      if (status == 429) {
        throw const AppException(
            'Too many requests. Please wait a moment and try again.');
      }
      if (status != null && status >= 500) {
        throw const AppException('AI service error. Please try again shortly.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  /// Gemini's 400 error body shape:
  /// { "error": { "message": "...", "status": "INVALID_ARGUMENT" } }
  String? _extractGeminiErrorMessage(dynamic data) {
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final msg = data['error']['message'];
      if (msg is String) return msg;
    }
    return null;
  }
}
