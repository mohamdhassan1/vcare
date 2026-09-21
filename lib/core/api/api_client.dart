import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Central Dio instance for the whole app.
///
/// Every data source (starting Phase 5) uses [dio] to make requests.
/// Base URL, headers, timeouts, the auth token, and request logging
/// are all configured once here instead of being repeated per feature.
class ApiClient {
  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(
      _tokenStorage,
      onUnauthorized: () => _sessionExpiredController.add(null),
    ));

    // Only log requests/responses in debug builds — never in release.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  final TokenStorage _tokenStorage;
  late final Dio dio;

  // Broadcast so the interceptor can fire regardless of whether the
  // auth layer has subscribed yet; lives for the whole app lifetime.
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  TokenStorage get tokenStorage => _tokenStorage;

  /// Emits once per rejected authenticated request (HTTP 401) after the
  /// stored token has already been cleared by [AuthInterceptor].
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;
}
