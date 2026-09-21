import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles for VCare, built on Inter.
///
/// Switched from Poppins (Phase 2 assumption) to Inter, confirmed as
/// the correct typeface from the official Design System image.
///
/// These styles carry NO color on purpose. A `Text` merges its style
/// with the surrounding `DefaultTextStyle`, so the color comes from the
/// active theme (light or dark) automatically. Secondary/hint text uses
/// the theme's `textTheme.bodySmall` / `labelSmall` (see AppTheme) or an
/// explicit `context.palette.*` color. Baking `AppColors.textPrimary`
/// in here is what made dark mode unreadable.
///
/// Inter has no Arabic glyphs, so every style falls back to the bundled
/// [arabicFontFamily] (Tajawal, see pubspec.yaml) for Arabic text. The
/// fallback is part of each style — not only the ThemeData — because a
/// widget-level style's `fontFamilyFallback` replaces the inherited one.
class AppTextStyles {
  AppTextStyles._();

  /// Bundled Arabic-capable family registered in pubspec.yaml.
  static const String arabicFontFamily = 'Tajawal';

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final style = GoogleFonts.inter(fontSize: fontSize, fontWeight: fontWeight);
    return style.copyWith(fontFamilyFallback: [
      ...?style.fontFamilyFallback,
      arabicFontFamily,
    ]);
  }

  static TextStyle get h1 => _inter(fontSize: 26, fontWeight: FontWeight.w700);

  static TextStyle get h2 => _inter(fontSize: 22, fontWeight: FontWeight.w700);

  static TextStyle get h3 => _inter(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle get bodyLarge =>
      _inter(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle get bodyMedium =>
      _inter(fontSize: 14, fontWeight: FontWeight.w400);

  /// Secondary text (13px). Use `context.textTheme.bodySmall` to get
  /// the theme's secondary color with it.
  static TextStyle get bodySmall =>
      _inter(fontSize: 13, fontWeight: FontWeight.w400);

  /// Caption text (12px). Use `context.textTheme.labelSmall` to get the
  /// theme's secondary color with it.
  static TextStyle get caption =>
      _inter(fontSize: 12, fontWeight: FontWeight.w400);

  static TextStyle get button =>
      _inter(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get link =>
      _inter(fontSize: 14, fontWeight: FontWeight.w500);
}
