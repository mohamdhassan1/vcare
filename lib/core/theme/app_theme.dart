import 'package:flutter/material.dart';
import 'app_dimensions.dart';
import 'app_page_transitions.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

/// Light and Dark [ThemeData] for VCare.
///
/// Both are produced by the same [_build] so every component used in
/// the app (inputs, buttons, chips, cards, sheets, dialogs, nav bar…)
/// is defined once and gets the right colors from an [AppPalette].
/// Widgets read mode-specific colors via `context.palette` and text
/// colors via `context.textTheme` — never from light-only constants.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final radiusMd = BorderRadius.circular(AppDimensions.radiusMd);
    final radiusLg = BorderRadius.circular(AppDimensions.radiusLg);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      surface: brightness == Brightness.light ? p.background : p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      error: p.error,
    );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      cardColor: p.surface,
      dividerColor: p.divider,
      extensions: [p],

      // Text: primary color for headings/body, secondary for small text.
      // Text widgets that use AppTextStyles.* inherit these colors.
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.h1.copyWith(color: p.textPrimary),
        headlineMedium: AppTextStyles.h2.copyWith(color: p.textPrimary),
        headlineSmall: AppTextStyles.h3.copyWith(color: p.textPrimary),
        titleMedium: AppTextStyles.bodyLarge.copyWith(color: p.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: p.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: p.textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: p.textSecondary),
        labelSmall: AppTextStyles.caption.copyWith(color: p.textSecondary),
        labelLarge: AppTextStyles.button.copyWith(color: p.onPrimary),
      ),
      iconTheme: IconThemeData(color: p.textPrimary),

      // Same fade+slide on every platform (web included).
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: VCarePageTransitionsBuilder(),
        TargetPlatform.iOS: VCarePageTransitionsBuilder(),
        TargetPlatform.linux: VCarePageTransitionsBuilder(),
        TargetPlatform.macOS: VCarePageTransitionsBuilder(),
        TargetPlatform.windows: VCarePageTransitionsBuilder(),
        TargetPlatform.fuchsia: VCarePageTransitionsBuilder(),
      }),

      // Flat bar with a hairline underneath so the header stays
      // anchored when a white body scrolls beneath a white bar.
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: p.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: p.divider)),
        centerTitle: false,
        iconTheme: IconThemeData(color: p.textPrimary),
        titleTextStyle: AppTextStyles.h3.copyWith(color: p.textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.primary.withValues(alpha: 0.5),
          disabledForegroundColor: p.onPrimary.withValues(alpha: 0.8),
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary),
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: p.primary, textStyle: AppTextStyles.link),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
      ),

      // Inputs: filled, no border at rest, brand border when focused.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.inputFill,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: p.textHint),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd, vertical: AppDimensions.spaceMd),
        border: OutlineInputBorder(
            borderRadius: radiusMd, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: radiusMd, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: radiusMd,
            borderSide: BorderSide(color: p.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: radiusMd,
            borderSide: BorderSide(color: p.error, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: radiusMd,
            borderSide: BorderSide(color: p.error, width: 1.5)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withValues(alpha: 0.3),
        selectionHandleColor: p.primary,
      ),

      // Surfaces.
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: radiusLg, side: BorderSide(color: p.cardBorder)),
      ),
      // Floating, rounded, high-contrast: dark on light, light on dark.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.textPrimary,
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: p.background),
        actionTextColor:
            brightness == Brightness.light ? p.primaryLight : p.primary,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
        insetPadding: const EdgeInsets.all(AppDimensions.spaceMd),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.primary,
        disabledColor: p.surface,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: p.textPrimary),
        secondaryLabelStyle:
            AppTextStyles.bodySmall.copyWith(color: p.onPrimary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: p.textPrimary,
        collapsedIconColor: p.textSecondary,
        textColor: p.textPrimary,
        collapsedTextColor: p.textPrimary,
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: p.background,
        surfaceTintColor: p.background,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.overlay,
        surfaceTintColor: p.overlay,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.overlay,
        surfaceTintColor: p.overlay,
        titleTextStyle: AppTextStyles.h3.copyWith(color: p.textPrimary),
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: p.textPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );

    // Material fills the text-theme slots we did not set from its own
    // defaults; give those the bundled Arabic fallback too so any
    // Material widget renders Arabic without a runtime font download.
    const fallback = ['Inter', AppTextStyles.arabicFontFamily];
    return theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamilyFallback: fallback),
      primaryTextTheme:
          theme.primaryTextTheme.apply(fontFamilyFallback: fallback),
    );
  }
}
