import 'package:flutter/material.dart';

/// Centralized color palette for VCare.
///
/// Primary color values below were sampled directly from pixel data in
/// the official Design System image (not estimated by eye), so they
/// are accurate. Other colors (surfaces, status, text) are still the
/// Phase 2 visual estimates and can be corrected the same way later
/// if needed — this update is scoped to Primary only, per project
/// decision.
class AppColors {
  AppColors._();

  // Brand — corrected from Design System (Primary 100 / darker variant)
  static const Color primary = Color(0xFF2A7CF9);
  static const Color primaryDark = Color(0xFF1E63D9);
  static const Color primaryLight = Color(0xFFEAF2FF);

  // Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color inputFill = Color(0xFFF1F2F6);

  // Text
  static const Color textPrimary = Color(0xFF1D2939);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders / dividers
  static const Color border = Color(0xFFE4E7EC);
  static const Color divider = Color(0xFFE5E7EB);

  // Status
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFEB5757);
  static const Color warning = Color(0xFFFFB800);

  // Rating stars
  static const Color star = Color(0xFFFFB800);
}
