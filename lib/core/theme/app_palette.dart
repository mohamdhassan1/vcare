import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic colors that differ between Light and Dark mode, attached
/// to each [ThemeData] as a [ThemeExtension] so widgets read them from
/// the *active* theme instead of the light-only [AppColors] constants.
///
/// Usage in a widget: `context.palette.surface`, `context.palette.textHint`.
/// Brand/status colors that are the same in both modes (error, star…)
/// are here too, so screens only need one import.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.overlay,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.divider,
    required this.cardBorder,
    required this.error,
    required this.success,
    required this.warning,
    required this.star,
  });

  /// Brand blue. Slightly lightened in dark mode for contrast.
  final Color primary;

  /// Text/icons drawn on top of [primary].
  final Color onPrimary;

  /// Soft brand tint: icon circles, price pills, unread highlights.
  final Color primaryLight;

  /// Scaffold / page background.
  final Color background;

  /// Cards, list tiles, chat bubbles, chips.
  final Color surface;

  /// Dialogs and bottom sheets (raised above [background]).
  final Color overlay;

  /// Text field fill and image placeholders.
  final Color inputFill;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color divider;

  /// Hairline around cards. Transparent in light mode (the surface tint
  /// is enough); a subtle line in dark mode where surface and background
  /// are too close for a card to read as a card.
  final Color cardBorder;

  final Color error;
  final Color success;
  final Color warning;
  final Color star;

  /// Values are the existing Figma-derived light tokens in [AppColors].
  static const AppPalette light = AppPalette(
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryLight: AppColors.primaryLight,
    background: AppColors.background,
    surface: AppColors.surface,
    overlay: AppColors.background,
    inputFill: AppColors.inputFill,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textHint: AppColors.textHint,
    border: AppColors.border,
    divider: AppColors.divider,
    cardBorder: Colors.transparent,
    error: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    star: AppColors.star,
  );

  /// Dark grey surfaces (not pure black), the same brand blue kept
  /// recognizable, WCAG-reasonable text contrast.
  static const AppPalette dark = AppPalette(
    primary: Color(0xFF5B9CFF),
    onPrimary: Colors.white,
    primaryLight: Color(0xFF1E2E4A),
    background: Color(0xFF121417),
    surface: Color(0xFF1E2126),
    overlay: Color(0xFF1E2126),
    inputFill: Color(0xFF262A31),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFFAAB0BA),
    textHint: Color(0xFF7C828C),
    border: Color(0xFF2E323A),
    divider: Color(0xFF2E323A),
    cardBorder: Color(0xFF2E323A),
    error: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    star: AppColors.star,
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? overlay,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? divider,
    Color? cardBorder,
    Color? error,
    Color? success,
    Color? warning,
    Color? star,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryLight: primaryLight ?? this.primaryLight,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      overlay: overlay ?? this.overlay,
      inputFill: inputFill ?? this.inputFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      cardBorder: cardBorder ?? this.cardBorder,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      star: star ?? this.star,
    );
  }

  // Value equality: Theme animation (AnimatedTheme) produces new lerped
  // instances, so two palettes with the same colors must compare equal.
  @override
  bool operator ==(Object other) =>
      other is AppPalette &&
      other.primary == primary &&
      other.onPrimary == onPrimary &&
      other.primaryLight == primaryLight &&
      other.background == background &&
      other.surface == surface &&
      other.overlay == overlay &&
      other.inputFill == inputFill &&
      other.textPrimary == textPrimary &&
      other.textSecondary == textSecondary &&
      other.textHint == textHint &&
      other.border == border &&
      other.divider == divider &&
      other.cardBorder == cardBorder &&
      other.error == error &&
      other.success == success &&
      other.warning == warning &&
      other.star == star;

  @override
  int get hashCode => Object.hash(
        primary,
        onPrimary,
        primaryLight,
        background,
        surface,
        overlay,
        inputFill,
        textPrimary,
        textSecondary,
        textHint,
        border,
        divider,
        cardBorder,
        error,
        success,
        warning,
        star,
      );

  /// Lets Flutter animate the Light ↔ Dark switch smoothly.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      star: Color.lerp(star, other.star, t)!,
    );
  }
}

/// Short accessors so screens don't repeat `Theme.of(context)...`.
extension AppThemeContext on BuildContext {
  /// The active theme's palette. Falls back to light if a test pumps a
  /// widget inside a plain MaterialApp without [AppTheme].
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// The active theme's text styles (colors already correct per mode).
  TextTheme get textTheme => Theme.of(this).textTheme;
}
