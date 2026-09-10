import '../../core/api/token_storage.dart';
import '../data_sources/user_remote_data_source.dart';
import '../models/user_profile_model.dart';

class UserRepository {
  UserRepository(this._remoteDataSource, this._tokenStorage);
  final UserRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  Future<UserProfileModel> getProfile() async {
    final profile = await _remoteDataSource.getProfile();
    if (profile.name.trim().isEmpty || profile.name.trim() == 'User') {
      final storedUsername = await _tokenStorage.getUsername();
      if (storedUsername != null && storedUsername.trim().isNotEmpty) {
        return UserProfileModel(
            name: storedUsername,
            email: profile.email,
            phone: profile.phone,
            imageUrl: profile.imageUrl);
      }
    }
    return profile;
  }

  Future<void> updateProfile(
      {required String name,
      required String email,
      required String phone,
      required String gender}) {
    return _remoteDataSource.updateProfile(
        name: name, email: email, phone: phone, gender: gender);
  }
}
