import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage, {this.onUnauthorized});
  final TokenStorage _tokenStorage;

  /// Invoked after the local token has been cleared because an
  /// authenticated request was rejected with HTTP 401. [ApiClient]
  /// forwards this to an app-level stream so the auth layer can move
  /// the user back to Sign In.
  final VoidCallback? onUnauthorized;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    debugPrint(
        '[HOME] ${options.method} ${options.path} — token attached: ${token != null && token.isNotEmpty}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isExpiredSession(err)) {
      debugPrint(
          '[AUTH] 401 on ${err.requestOptions.path} — clearing local session.');
      // Clear first so any request issued from now on goes out without
      // the dead token; then let the auth layer react once.
      await _tokenStorage.clearToken();
      onUnauthorized?.call();
    }
    // Always propagate: callers still get their UnauthorizedException.
    handler.next(err);
  }

  /// A 401 only means "session expired" when the request actually
  /// carried a token. Login/register 401s are wrong credentials, and
  /// logout tears the local session down itself — neither should
  /// trigger the global redirect.
  bool _isExpiredSession(DioException err) {
    if (err.response?.statusCode != 401) return false;
    if (err.requestOptions.headers['Authorization'] == null) return false;
    if (err.requestOptions.path == ApiEndpoints.logout) return false;
    return true;
  }
}
