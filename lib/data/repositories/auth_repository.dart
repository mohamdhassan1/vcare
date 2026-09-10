import '../../core/api/token_storage.dart';
import '../data_sources/auth_remote_data_source.dart';
import 'profile_photo_repository.dart';

class AuthRepository {
  AuthRepository(
      this._remoteDataSource, this._tokenStorage, this._profilePhotoRepository);
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final ProfilePhotoRepository _profilePhotoRepository;

  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _remoteDataSource.register(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      gender: gender,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    await _tokenStorage.saveToken(result.token);
    await _tokenStorage.saveUsername(result.username);
    return result.username;
  }

  Future<String> login(
      {required String email, required String password}) async {
    final result = await _remoteDataSource.login(
        email: email.trim().toLowerCase(), password: password);
    await _tokenStorage.saveToken(result.token);
    await _tokenStorage.saveUsername(result.username);
    return result.username;
  }

  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _tokenStorage.clearToken();
      // Prevents User A's cached name/photo from ever appearing for
      // User B on the next login.
      await _profilePhotoRepository.clearPhoto();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
