/// Centralized spacing and radius values used across VCare.
///
/// Keeps padding/margins/corner-radius consistent without hardcoding
/// numbers in every widget.
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // Border radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 100;

  // Icon sizing
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 48;

  // Component sizing
  static const double buttonHeight = 52;
  static const double inputHeight = 52;

  /// Smallest comfortable tap target (Material / WCAG guidance).
  static const double minTouchTarget = 48;

  /// Widest a column of scrollable content should get on web/desktop;
  /// wider screens center it (see ContentConstraint).
  static const double contentMaxWidth = 640;
}

/// Motion timings. Short on purpose: motion should confirm an action,
/// never delay it. Pass through `context.motion(...)` so they collapse
/// to zero when the OS asks for reduced motion.
class AppDurations {
  AppDurations._();

  /// Micro feedback: icon swaps, chip selection, button label ↔ spinner.
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard: page transitions, state switches, fade-ins.
  static const Duration normal = Duration(milliseconds: 220);

  /// Emphasis: success check, splash logo.
  static const Duration slow = Duration(milliseconds: 300);
}
