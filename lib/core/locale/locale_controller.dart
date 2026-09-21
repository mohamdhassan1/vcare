import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists selected locale via the storage mechanism already used
/// for tokens/username/favorites (flutter_secure_storage) — no new
/// dependency needed.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController(super.initial);
  static const _key = 'app_locale';
  static const Duration _readTimeout = Duration(seconds: 5);
  final _storage = const FlutterSecureStorage();

  /// Called exactly once from `main()` before `runApp`, so the very
  /// first frame already uses the persisted choice. Never throws: a
  /// storage failure or hang keeps the initial locale so it can never
  /// block startup (same pattern as TokenStorage.getToken).
  Future<void> load() async {
    try {
      final saved = await _storage
          .read(key: _key)
          .timeout(_readTimeout, onTimeout: () => null);
      if (saved != null) value = Locale(saved);
    } catch (e) {
      debugPrint('[LOCALE] Read failed: $e — keeping default.');
    }
  }

  Future<void> setLocale(Locale locale) async {
    value = locale;
    await _storage.write(key: _key, value: locale.languageCode);
  }
}
