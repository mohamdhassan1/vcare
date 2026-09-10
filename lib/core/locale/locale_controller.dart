import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists selected locale via the storage mechanism already used
/// for tokens/username/favorites (flutter_secure_storage) — no new
/// dependency needed.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController(super.initial);
  static const _key = 'app_locale';
  final _storage = const FlutterSecureStorage();

  Future<void> load() async {
    final saved = await _storage.read(key: _key);
    if (saved != null) value = Locale(saved);
  }

  Future<void> setLocale(Locale locale) async {
    value = locale;
    await _storage.write(key: _key, value: locale.languageCode);
  }
}
