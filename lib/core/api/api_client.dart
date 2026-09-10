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

    dio.interceptors.add(AuthInterceptor(_tokenStorage));

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

  TokenStorage get tokenStorage => _tokenStorage;
}
