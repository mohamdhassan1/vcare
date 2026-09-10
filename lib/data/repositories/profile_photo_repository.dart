import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// No VCare API supports profile-image upload (confirmed absent from
/// Postman). Genuinely persistent local-only storage: bytes are
/// written to a file in the app's permanent documents directory
/// (survives restarts, unlike image_picker's own temp cache path),
/// with the file path saved in secure storage for reload on startup.
class ProfilePhotoRepository {
  ProfilePhotoRepository({ImagePicker? picker, FlutterSecureStorage? storage})
      : _picker = picker ?? ImagePicker(),
        _storage = storage ?? const FlutterSecureStorage();

  final ImagePicker _picker;
  final FlutterSecureStorage _storage;
  static const _pathKey = 'profile_photo_path';

  /// Called on ProfileStarted — restores the saved photo, if any.
  Future<Uint8List?> loadSavedPhoto() async {
    final path = await _storage.read(key: _pathKey);
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) {
      // File was deleted/missing — clean up the dangling reference
      // rather than crashing or repeatedly trying to read it.
      await _storage.delete(key: _pathKey);
      return null;
    }
    return file.readAsBytes();
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
        source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    await _persist(bytes);
    return bytes;
  }

  Future<void> _persist(Uint8List bytes) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final savedPath = '${docsDir.path}/profile_photo.jpg';
    final oldPath = await _storage.read(key: _pathKey);
    if (oldPath != null && oldPath != savedPath) {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) await oldFile.delete();
    }
    await File(savedPath).writeAsBytes(bytes);
    await _storage.write(key: _pathKey, value: savedPath);
  }

  Future<void> clearPhoto() async {
    final path = await _storage.read(key: _pathKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
      await _storage.delete(key: _pathKey);
    }
  }
}
