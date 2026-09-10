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

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 100;

  // Component sizing
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
}
