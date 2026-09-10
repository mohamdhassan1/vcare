import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local-only favorite doctor IDs. No VCare API supports favorites
/// (confirmed absent from the full Postman collection) — this is an
/// honest, on-device-only feature, never presented as synced to the
/// backend. Reuses the flutter_secure_storage dependency already in
/// the project (Phase 4) rather than adding a new package.
class FavoritesLocalDataSource {
  FavoritesLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _key = 'favorite_doctor_ids';

  Future<Set<int>> getFavoriteIds() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  Future<void> saveFavoriteIds(Set<int> ids) async {
    await _storage.write(key: _key, value: ids.join(','));
  }
}
