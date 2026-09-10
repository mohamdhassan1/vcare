import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Single source of truth for the app's ThemeMode. Instantiated once
/// in main.dart and survives MaterialApp rebuilds (locale changes,
/// etc.) because it lives above them in the widget tree via
/// ListenableProvider, exactly like LocaleController.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController(super.initial) : _storage = const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  static const _key = 'app_theme';

  Future<void> load() async {
    final saved = await _storage.read(key: _key);
    switch (saved) {
      case 'light':
        value = ThemeMode.light;
        break;
      case 'dark':
        value = ThemeMode.dark;
        break;
      case 'system':
        value = ThemeMode.system;
        break;
      default:
        // No saved value at all (first launch) → system default.
        // Note: this does NOT overwrite an existing saved 'system'
        // choice — that's handled by the 'system' case above, so a
        // user who explicitly chose System Default still has that
        // choice persisted and reloaded, not just defaulted blindly.
        value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    await _storage.write(
      key: _key,
      value: mode == ThemeMode.light
          ? 'light'
          : (mode == ThemeMode.dark ? 'dark' : 'system'),
    );
  }
}
