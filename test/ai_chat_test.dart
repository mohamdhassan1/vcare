// B11 / Phase 4 — Gemini config, transport and parsing failures become
// handled, user-safe failures (never a crash, never a silently empty
// answer, never the key); the failed message and its error stay visible
// until the user retries, dismisses, or sends something new.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/config/env_config.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/data/data_sources/gemini_remote_data_source.dart';
import 'package:vcare/data/models/ai_message_model.dart';
import 'package:vcare/data/repositories/ai_chat_repository.dart';
import 'package:vcare/logic/blocs/ai_chat/ai_chat_bloc.dart';
import 'package:vcare/logic/blocs/ai_chat/ai_chat_event.dart';

/// Replaces Dio's HTTP layer so no network (and no real key) is needed.
class _FakeHttpAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  late Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    lastRequest = options;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );

const _dummyKey = 'test-key-not-real';

void main() {
  group('GeminiRemoteDataSource', () {
    late _FakeHttpAdapter adapter;
    late GeminiRemoteDataSource source;
    final history = [
      const AIMessageModel(role: AIMessageRole.user, text: 'Hello')
    ];

    setUp(() {
      adapter = _FakeHttpAdapter();
      source = GeminiRemoteDataSource(
          dio: Dio()..httpClientAdapter = adapter, apiKey: _dummyKey);
    });

    test('sends the key as a header with explicit timeouts, returns text',
        () async {
      adapter.handler = (_) async => _json({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Hi '},
                    {'text': 'there'}
                  ]
                }
              }
            ]
          }, 200);

      expect(await source.sendMessage(history), 'Hi there');

      final request = adapter.lastRequest!;
      expect(request.headers['X-goog-api-key'], _dummyKey);
      expect(request.sendTimeout, GeminiRemoteDataSource.sendTimeout);
      expect(request.receiveTimeout, GeminiRemoteDataSource.receiveTimeout);
      expect(request.uri.toString(), isNot(contains(_dummyKey)),
          reason: 'key must never be part of the URL');
      // History is forwarded as Gemini "contents".
      expect((request.data as Map)['contents'], hasLength(1));
    });

    test('a receive timeout becomes a handled AppException', () async {
      adapter.handler = (options) async => throw DioException.receiveTimeout(
          timeout: GeminiRemoteDataSource.receiveTimeout,
          requestOptions: options);

      await expectLater(
        source.sendMessage(history),
        throwsA(isA<AppException>().having((e) => e.message, 'message',
            'The assistant took too long to respond. Please try again.')),
      );
    });

    test('send and connection timeouts map to aiTimeout too', () async {
      adapter.handler = (options) async => throw DioException.sendTimeout(
          timeout: GeminiRemoteDataSource.sendTimeout, requestOptions: options);
      await expectLater(
          source.sendMessage(history),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'code', AppErrorCode.aiTimeout)));

      adapter.handler = (options) async => throw DioException.connectionTimeout(
          timeout: GeminiRemoteDataSource.connectTimeout,
          requestOptions: options);
      await expectLater(
          source.sendMessage(history),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'code', AppErrorCode.aiTimeout)));
    });

    test('a connection error becomes the standard network failure', () async {
      adapter.handler = (options) async => throw DioException.connectionError(
          requestOptions: options, reason: 'socket');
      await expectLater(
          source.sendMessage(history), throwsA(isA<NetworkException>()));
    });

    test('HTTP errors are mapped without leaking Google\'s message', () async {
      adapter.handler = (_) async => _json({
            'error': {'message': 'Quota exceeded for model secret-model-x'}
          }, 429);

      await expectLater(
        source.sendMessage(history),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('Too many requests'))
            .having((e) => e.message, 'no internals',
                isNot(contains('secret-model-x')))),
      );
    });

    group('HTTP status → stable error code', () {
      Future<AppException> failWith(int status) async {
        adapter.handler = (_) async => _json({
              'error': {'message': 'internal detail model-z'}
            }, status);
        try {
          await source.sendMessage(history);
        } on AppException catch (e) {
          return e;
        }
        fail('expected an AppException');
      }

      test('400 → aiInvalidRequest', () async {
        expect((await failWith(400)).code, AppErrorCode.aiInvalidRequest);
      });
      test('401/403 → aiInvalidKey, without the provider\'s wording', () async {
        for (final status in [401, 403]) {
          final e = await failWith(status);
          expect(e.code, AppErrorCode.aiInvalidKey);
          expect(e.message, isNot(contains('model-z')));
        }
      });
      test('429 → aiRateLimited', () async {
        expect((await failWith(429)).code, AppErrorCode.aiRateLimited);
      });
      test('500/503 → aiServiceError', () async {
        expect((await failWith(500)).code, AppErrorCode.aiServiceError);
        expect((await failWith(503)).code, AppErrorCode.aiServiceError);
      });
      test('other statuses → generic unknown failure', () async {
        expect((await failWith(418)).code, AppErrorCode.unknown);
      });
    });

    test('a 200 with an unparseable body is a handled failure', () async {
      adapter.handler =
          (_) async => ResponseBody.fromString('<html>', 200, headers: {
                Headers.contentTypeHeader: ['text/html']
              });
      await expectLater(
          source.sendMessage(history),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'code', AppErrorCode.aiEmptyResponse)));
    });

    test('a missing key fails before any request is made', () async {
      final noKey = GeminiRemoteDataSource(
          dio: Dio()..httpClientAdapter = adapter, apiKey: '');
      adapter.handler = (_) async => fail('must not call the network');
      await expectLater(
        noKey.sendMessage(history),
        throwsA(isA<AppException>()
            .having((e) => e.code, 'code', AppErrorCode.aiNotConfigured)
            .having(
                (e) => e.message,
                'no config internals',
                isNot(anyOf(contains('GEMINI_API_KEY'), contains('dart-define'),
                    contains('googleapis'))))),
      );
      expect(adapter.lastRequest, isNull);
    });

    test('the key never appears in the URL, body or debug log', () async {
      final log = <String>[];
      final previous = debugPrint;
      debugPrint = (String? m, {int? wrapWidth}) => log.add(m ?? '');
      addTearDown(() => debugPrint = previous);

      adapter.handler = (_) async => _json({
            'error': {'message': 'API key not valid'}
          }, 401);

      await expectLater(
          source.sendMessage(history), throwsA(isA<AppException>()));

      final request = adapter.lastRequest!;
      expect(request.uri.toString(), isNot(contains(_dummyKey)));
      expect(jsonEncode(request.data), isNot(contains(_dummyKey)));
      expect(log, isNotEmpty);
      expect(log.join('\n'), isNot(contains(_dummyKey)));
      expect(log.join('\n'), contains('API key present: true'),
          reason: 'only the boolean presence is logged');
    });
  });

  group('EnvConfig', () {
    test('hasGeminiKey mirrors the compile-time define (empty in tests)', () {
      // No --dart-define is passed to the test run, so the key is empty
      // and the app must report "not configured" instead of calling out.
      expect(EnvConfig.hasGeminiKey, EnvConfig.geminiApiKey.isNotEmpty);
      expect(EnvConfig.geminiApiKey, isEmpty,
          reason: 'tests must never run with a real key');
      expect(EnvConfig.hasGeminiKey, isFalse);
    });
  });

  group('GeminiRemoteDataSource.parseGeneratedText', () {
    AppErrorCode? codeOf(dynamic data) {
      try {
        GeminiRemoteDataSource.parseGeneratedText(data);
      } on AppException catch (e) {
        return e.code;
      }
      return null;
    }

    Map<String, dynamic> candidate(Map<String, dynamic> c) => {
          'candidates': [c]
        };

    test('joins all text parts of the first candidate', () {
      expect(
          GeminiRemoteDataSource.parseGeneratedText(candidate({
            'content': {
              'parts': [
                {'text': 'A'},
                {'inlineData': <String, dynamic>{}},
                {'text': 'B'}
              ]
            }
          })),
          'AB');
    });

    test('never throws a TypeError on unexpected shapes', () {
      final odd = <dynamic>[
        null,
        'string',
        42,
        <dynamic>[],
        <String, dynamic>{},
        {'candidates': null},
        {'candidates': 'nope'},
        {'candidates': <dynamic>[]},
        {
          'candidates': <dynamic>[null]
        },
        {
          'candidates': <dynamic>['x']
        },
        candidate({}),
        candidate({'content': null}),
        candidate({'content': 'text'}),
        candidate({'content': <String, dynamic>{}}),
        candidate({
          'content': {'parts': null}
        }),
        candidate({
          'content': {'parts': <dynamic>[]}
        }),
        candidate({
          'content': {
            'parts': [
              {'text': null}
            ]
          }
        }),
        candidate({
          'content': {
            'parts': [
              {'text': '   \n'}
            ]
          }
        }),
        candidate({
          'content': {
            'parts': [
              {'functionCall': <String, dynamic>{}}
            ]
          }
        }),
        {
          'error': {'message': 'boom'}
        },
      ];
      for (final data in odd) {
        expect(codeOf(data), AppErrorCode.aiEmptyResponse,
            reason: 'input: $data');
      }
    });

    test('a blocked prompt or SAFETY finish is reported as aiBlocked', () {
      expect(
          codeOf({
            'promptFeedback': {'blockReason': 'SAFETY'},
            'candidates': <dynamic>[]
          }),
          AppErrorCode.aiBlocked);
      for (final reason in ['SAFETY', 'RECITATION', 'safety']) {
        expect(
            codeOf(candidate({
              'finishReason': reason,
              'content': {'parts': <dynamic>[]}
            })),
            AppErrorCode.aiBlocked,
            reason: reason);
      }
      // A normal STOP with text is fine.
      expect(
          GeminiRemoteDataSource.parseGeneratedText(candidate({
            'finishReason': 'STOP',
            'content': {
              'parts': [
                {'text': 'ok'}
              ]
            }
          })),
          'ok');
    });
  });

  group('AIChatBloc', () {
    late _FakeAIChatRepository repo;
    late AIChatBloc bloc;

    setUp(() {
      repo = _FakeAIChatRepository();
      bloc = AIChatBloc(repo);
    });

    tearDown(() => bloc.close());

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 20));

    test('successful flow: user + model messages, no error', () async {
      repo.reply = 'Sure!';
      bloc.add(const AIChatMessageSent('Hi'));
      await settle();

      expect(bloc.state.isSending, isFalse);
      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.messages.map((m) => m.text), ['Hi', 'Sure!']);
      expect(bloc.state.messages.any((m) => m.failed), isFalse);
    });

    test('failure keeps the message (marked failed) with a visible error',
        () async {
      repo.error = const AppException('The assistant took too long.');
      bloc.add(const AIChatMessageSent('Hi'));
      await settle();

      final state = bloc.state;
      expect(state.isSending, isFalse, reason: 'never stuck loading');
      expect(state.errorMessage, 'The assistant took too long.');
      expect(state.failedMessage?.text, 'Hi');
      expect(state.messages.single.failed, isTrue);

      // The error survives until the user acts on it.
      await settle();
      expect(bloc.state.errorMessage, isNotNull);
    });

    test('retry re-sends the failed text and clears the error on success',
        () async {
      repo.error = const NetworkException();
      bloc.add(const AIChatMessageSent('Hi'));
      await settle();

      repo.error = null;
      repo.reply = 'Back online';
      bloc.add(const AIChatRetryRequested());
      await settle();

      expect(repo.lastHistory.map((m) => m.text), ['Hi']);
      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.messages.map((m) => m.text), ['Hi', 'Back online']);
      expect(bloc.state.failedMessage, isNull);
    });

    test('retry that fails again never duplicates the user message', () async {
      repo.error = const NetworkException();
      bloc.add(const AIChatMessageSent('Hi'));
      await settle();
      bloc.add(const AIChatRetryRequested());
      await settle();

      expect(bloc.state.messages.where((m) => m.text == 'Hi'), hasLength(1));
      expect(bloc.state.failedMessage?.text, 'Hi');
      expect(repo.lastHistory.where((m) => m.failed), isEmpty,
          reason: 'a failed turn is never sent to Gemini');
      expect(bloc.state.errorMessage, isNotNull);
    });

    test('a new message replaces the failed one and excludes it from history',
        () async {
      repo.reply = 'A1';
      bloc.add(const AIChatMessageSent('Q1'));
      await settle();

      repo.error = const NetworkException();
      bloc.add(const AIChatMessageSent('Q2'));
      await settle();
      expect(bloc.state.failedMessage?.text, 'Q2');

      repo.error = null;
      repo.reply = 'A3';
      bloc.add(const AIChatMessageSent('Q3'));
      await settle();

      expect(repo.lastHistory.map((m) => m.text), ['Q1', 'A1', 'Q3'],
          reason: 'the unanswered Q2 must not be sent to Gemini');
      expect(bloc.state.messages.map((m) => m.text), ['Q1', 'A1', 'Q3', 'A3']);
      expect(bloc.state.errorMessage, isNull);
    });

    test('dismiss drops the failed message and the error', () async {
      repo.error = const NetworkException();
      bloc.add(const AIChatMessageSent('Hi'));
      await settle();

      bloc.add(const AIChatErrorDismissed());
      await settle();
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.errorMessage, isNull);
    });

    test('a send while already sending is ignored (no duplicate turns)',
        () async {
      final gate = Completer<String>();
      repo.replyFuture = gate.future;
      bloc.add(const AIChatMessageSent('One'));
      await settle();
      expect(bloc.state.isSending, isTrue);

      bloc.add(const AIChatMessageSent('Two'));
      await settle();
      gate.complete('Answer');
      await settle();

      expect(bloc.state.messages.map((m) => m.text), ['One', 'Answer']);
      expect(bloc.state.isSending, isFalse);
    });

    test('history stays in user/model order across many turns', () async {
      for (var i = 1; i <= 3; i++) {
        repo.reply = 'A$i';
        bloc.add(AIChatMessageSent('Q$i'));
        await settle();
      }
      final msgs = bloc.state.messages;
      expect(msgs.map((m) => m.text), ['Q1', 'A1', 'Q2', 'A2', 'Q3', 'A3']);
      expect(msgs.map((m) => m.role), [
        AIMessageRole.user,
        AIMessageRole.model,
        AIMessageRole.user,
        AIMessageRole.model,
        AIMessageRole.user,
        AIMessageRole.model,
      ]);
      expect(
          repo.lastHistory.map((m) => m.text), ['Q1', 'A1', 'Q2', 'A2', 'Q3'],
          reason: 'the whole answered thread precedes the new question');
      expect(msgs.last.toGeminiPart()['role'], 'model');
    });

    test('the error carries a stable code for localization', () async {
      repo.error = const AppException('raw', code: AppErrorCode.aiTimeout);
      bloc.add(const AIChatMessageSent('Hi'));
      await settle();
      expect(bloc.state.error?.code, AppErrorCode.aiTimeout);
    });

    test('unexpected (non-App) exceptions are still handled', () async {
      repo.error = StateError('boom');
      bloc.add(const AIChatMessageSent('Hi'));
      await settle();
      expect(bloc.state.isSending, isFalse);
      expect(
          bloc.state.errorMessage, 'Something went wrong. Please try again.');
      expect(bloc.state.errorMessage, isNot(contains('boom')));
    });
  });
}

class _FakeAIChatRepository implements AIChatRepository {
  String reply = 'ok';
  Future<String>? replyFuture;
  Object? error;
  List<AIMessageModel> lastHistory = const [];

  @override
  Future<String> sendMessage(List<AIMessageModel> history) async {
    lastHistory = List.of(history);
    if (error != null) throw error!;
    if (replyFuture != null) return replyFuture!;
    return reply;
  }
}
