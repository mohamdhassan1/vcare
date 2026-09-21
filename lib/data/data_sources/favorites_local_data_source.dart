import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local-only favorite doctor IDs. No VCare API supports favorites
/// (confirmed absent from the full Postman collection) — this is an
/// honest, on-device-only feature, never presented as synced to the
/// backend. Reuses the flutter_secure_storage dependency already in
/// the project (Phase 4) rather than adding a new package.
///
/// Favorites are scoped per account: the stored value is a JSON map of
/// `userKey → [doctorId, ...]`, so User B never sees User A's hearts on
/// a shared device, and User A gets theirs back after signing in again.
/// (The pre-Phase-1C format was a single comma-separated list with no
/// owner; it cannot be attributed to anyone and is ignored.)
class FavoritesLocalDataSource {
  FavoritesLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _key = 'favorite_doctor_ids';

  /// Favorites of one account. Storage errors propagate to the caller
  /// (the bloc turns them into an error state) — nothing is swallowed.
  Future<Set<int>> getFavoriteIds(String userKey) async {
    final raw = await _storage.read(key: _key);
    return decode(raw)[userKey] ?? <int>{};
  }

  /// Replaces the favorites of one account, leaving other accounts'
  /// entries untouched.
  Future<void> saveFavoriteIds(String userKey, Set<int> ids) async {
    final all = decode(await _storage.read(key: _key));
    if (ids.isEmpty) {
      all.remove(userKey);
    } else {
      all[userKey] = ids;
    }
    await _storage.write(key: _key, value: encode(all));
  }

  /// Parses the stored JSON map. Anything that isn't a JSON object of
  /// `string → list of ints` (null, the legacy "1,2,3" format, corrupt
  /// data) yields an empty map rather than throwing.
  @visibleForTesting
  static Map<String, Set<int>> decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    final dynamic parsed;
    try {
      parsed = jsonDecode(raw);
    } on FormatException {
      return {};
    }
    if (parsed is! Map<String, dynamic>) return {};

    final result = <String, Set<int>>{};
    parsed.forEach((userKey, value) {
      if (value is! List) return;
      final ids = value.whereType<num>().map((n) => n.toInt()).toSet();
      if (ids.isNotEmpty) result[userKey] = ids;
    });
    return result;
  }

  @visibleForTesting
  static String encode(Map<String, Set<int>> all) {
    return jsonEncode(
        all.map((userKey, ids) => MapEntry(userKey, ids.toList()..sort())));
  }
}
