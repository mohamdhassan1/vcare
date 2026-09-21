import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'auth_username';
  static const String _userEmailKey = 'auth_user_email';
  static const Duration _readTimeout = Duration(seconds: 5);

  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey).timeout(
        _readTimeout,
        onTimeout: () {
          debugPrint(
              '[TOKEN] Read timed out after ${_readTimeout.inSeconds}s — treating as no token.');
          return null;
        },
      );
      debugPrint('[TOKEN] Available: ${token != null && token.isNotEmpty}');
      return token;
    } catch (e) {
      debugPrint('[TOKEN] Read failed: $e — treating as no token.');
      return null;
    }
  }

  Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }

  /// Saves the username returned by /auth/login or /auth/register.
  /// Used as an honest fallback if /user/profile ever omits a name —
  /// this is real data from the same authenticated session, not
  /// invented.
  Future<void> saveUsername(String username) {
    return _storage.write(key: _usernameKey, value: username);
  }

  Future<String?> getUsername() async {
    try {
      return await _storage.read(key: _usernameKey);
    } catch (e) {
      return null;
    }
  }

  /// The (normalised) email the user signed in / registered with. It is
  /// the account identifier the backend authenticates, so it's the
  /// stable identity used to keep device-local data (favorites) scoped
  /// to one account. The API's `username` is only a display name and
  /// is not guaranteed unique, so it is not used for this.
  Future<void> saveUserEmail(String email) {
    return _storage.write(key: _userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUserEmail() {
    return _storage.delete(key: _userEmailKey);
  }
}
