import 'package:flutter/foundation.dart';

import '../../core/api/token_storage.dart';
import '../data_sources/auth_remote_data_source.dart';
import 'profile_photo_repository.dart';

class AuthRepository {
  AuthRepository(
    this._remoteDataSource,
    this._tokenStorage,
    this._profilePhotoRepository, {
    Stream<void>? sessionExpired,
  }) : _sessionExpired = sessionExpired ?? const Stream<void>.empty();

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final ProfilePhotoRepository _profilePhotoRepository;
  final Stream<void> _sessionExpired;

  /// Fires when the backend rejects the stored token (HTTP 401). By the
  /// time this emits, the token has already been removed from storage,
  /// so listeners only need to move the user back to Sign In.
  Stream<void> get sessionExpired => _sessionExpired;

  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
    required String passwordConfirmation,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final result = await _remoteDataSource.register(
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      gender: gender,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    await _tokenStorage.saveToken(result.token);
    await _tokenStorage.saveUsername(result.username);
    // Account identity for device-local, per-user data (favorites).
    await _tokenStorage.saveUserEmail(normalizedEmail);
    return result.username;
  }

  Future<String> login(
      {required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final result = await _remoteDataSource.login(
        email: normalizedEmail, password: password);
    await _tokenStorage.saveToken(result.token);
    await _tokenStorage.saveUsername(result.username);
    await _tokenStorage.saveUserEmail(normalizedEmail);
    return result.username;
  }

  /// Best-effort server logout, then guaranteed local teardown.
  ///
  /// The remote call can fail for reasons the user cannot fix from a
  /// logout button (offline, timeout, 5xx, already-invalid token). None
  /// of those should leave the device authenticated, and none should
  /// surface as an error — the user asked to leave, so we let them.
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      // Only the mapped message is logged — never a response body.
      debugPrint(
          '[AUTH] Server logout failed ($e) — clearing local session anyway.');
    }
    await _tokenStorage.clearToken();
    // No signed-in account any more, so device-local per-user data
    // (favorites) resolves to "nobody" until the next login. The
    // favorites themselves stay stored under this user's email so they
    // are back if the same account signs in again.
    await _tokenStorage.clearUserEmail();
    // Prevents User A's cached name/photo from ever appearing for
    // User B on the next login.
    await _profilePhotoRepository.clearPhoto();
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
