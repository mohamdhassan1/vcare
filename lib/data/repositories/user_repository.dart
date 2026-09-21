import '../../core/api/token_storage.dart';
import '../data_sources/user_remote_data_source.dart';
import '../models/user_profile_model.dart';

class UserRepository {
  UserRepository(this._remoteDataSource, this._tokenStorage);
  final UserRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  /// Shown only when neither the API nor the login response gave us a
  /// name — never used to paper over a parsing problem.
  static const String _fallbackName = 'User';

  Future<UserProfileModel> getProfile() async {
    final profile = await _remoteDataSource.getProfile();
    if (profile.hasName) return profile;

    // Honest fallback: the username returned by /auth/login for this
    // same session, then a generic label as the very last resort.
    final storedUsername = await _tokenStorage.getUsername();
    final fallback =
        (storedUsername != null && storedUsername.trim().isNotEmpty)
            ? storedUsername.trim()
            : _fallbackName;
    return profile.copyWith(name: fallback);
  }

  /// The username saved from /auth/login or /auth/register for this
  /// session, or null. Lets Home still greet the user when the profile
  /// request itself fails — real session data, never invented.
  Future<String?> getStoredUsername() async {
    final username = await _tokenStorage.getUsername();
    if (username == null || username.trim().isEmpty) return null;
    return username.trim();
  }

  /// [password] is forwarded only when non-empty; the data source omits
  /// the field entirely otherwise (see UserRemoteDataSource).
  Future<void> updateProfile(
      {required String name,
      required String email,
      required String phone,
      required String gender,
      String? password}) {
    return _remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        password: password);
  }
}
