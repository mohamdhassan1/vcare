import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Local-only profile photo storage. No VCare API endpoint accepts a
/// profile image upload (confirmed absent from the Postman collection),
/// so this is honestly device-local — never presented as synced to
/// the server.
class ProfilePhotoLocalDataSource {
  ProfilePhotoLocalDataSource(
      {FlutterSecureStorage? storage, ImagePicker? picker})
      : _storage = storage ?? const FlutterSecureStorage(),
        _picker = picker ?? ImagePicker();

  final FlutterSecureStorage _storage;
  final ImagePicker _picker;
  static const String _key = 'profile_photo_path';

  Future<String?> getSavedPhotoPath() async {
    final path = await _storage.read(key: _key);
    if (path != null && await File(path).exists()) return path;
    return null;
  }

  /// Returns the new local file path, or null if the user cancelled.
  Future<String?> pickAndSaveImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
        source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return null;
    final docsDir = await getApplicationDocumentsDirectory();
    final savedPath = '${docsDir.path}/profile_photo.jpg';
    await File(picked.path).copy(savedPath);
    await _storage.write(key: _key, value: savedPath);
    return savedPath;
  }
}
