import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// No VCare API supports profile-image upload (confirmed absent from
/// Postman), so the photo is honestly device-local and never presented
/// as server-side profile data.
///
/// Persistence differs per platform:
/// - Android/desktop: bytes are written to a file in the app's
///   permanent documents directory (survives restarts, unlike
///   image_picker's temp cache) and the path is kept in secure storage.
/// - Web: there is no documents directory and `dart:io` is unavailable
///   at runtime, so the (already down-scaled, ≤1024px / q85) bytes are
///   stored base64-encoded in the same secure storage, which is backed
///   by the browser's localStorage. No extra dependency needed.
///
/// Nothing here swallows errors: callers (ProfileBloc) decide how to
/// surface a failed load/save/remove to the user.
class ProfilePhotoRepository {
  ProfilePhotoRepository({ImagePicker? picker, FlutterSecureStorage? storage})
      : _picker = picker ?? ImagePicker(),
        _storage = storage ?? const FlutterSecureStorage();

  final ImagePicker _picker;
  final FlutterSecureStorage _storage;

  /// Native platforms: absolute path of the saved JPEG.
  static const _pathKey = 'profile_photo_path';

  /// Web: base64 of the saved JPEG bytes.
  static const _webBytesKey = 'profile_photo_b64';

  /// Called on ProfileStarted — restores the saved photo, if any.
  /// Returns null when nothing is saved. Throws when a saved photo
  /// exists but cannot be read, after removing the unreadable entry so
  /// the failure is reported once rather than on every launch.
  Future<Uint8List?> loadSavedPhoto() async {
    if (kIsWeb) {
      final encoded = await _storage.read(key: _webBytesKey);
      if (encoded == null || encoded.isEmpty) return null;
      try {
        return base64Decode(encoded);
      } on FormatException {
        await _storage.delete(key: _webBytesKey);
        rethrow;
      }
    }

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

  /// Opens the picker only. Returns null if the user cancelled.
  /// Persisting is a separate step ([savePhoto]) so a storage failure
  /// can be reported distinctly from a cancelled pick.
  Future<Uint8List?> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
        source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return null;
    return picked.readAsBytes();
  }

  /// Persists [bytes] so [loadSavedPhoto] returns them after a restart.
  Future<void> savePhoto(Uint8List bytes) async {
    if (kIsWeb) {
      await _storage.write(key: _webBytesKey, value: base64Encode(bytes));
      return;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final savedPath = '${docsDir.path}/profile_photo.jpg';
    final oldPath = await _storage.read(key: _pathKey);
    if (oldPath != null && oldPath != savedPath) {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) await oldFile.delete();
    }
    await File(savedPath).writeAsBytes(bytes, flush: true);
    await _storage.write(key: _pathKey, value: savedPath);
  }

  /// Removes the persisted photo on every platform. Safe to call when
  /// nothing is saved (used by logout as well as "Remove Photo").
  Future<void> clearPhoto() async {
    if (kIsWeb) {
      await _storage.delete(key: _webBytesKey);
      return;
    }

    final path = await _storage.read(key: _pathKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } on FileSystemException catch (e) {
          // The reference is still removed below, so the photo will not
          // be restored; the orphaned file is harmless.
          debugPrint('[PHOTO] Could not delete old file: ${e.message}');
        }
      }
      await _storage.delete(key: _pathKey);
    }
  }
}
