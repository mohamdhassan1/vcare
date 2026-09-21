// Phase 2 — theme system: both ThemeData build, carry the brand color
// and the AppPalette extension, text inherits the right color per mode,
// and ThemeController persists/restores the choice via secure storage.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/theme/app_colors.dart';
import 'package:vcare/core/theme/app_palette.dart';
import 'package:vcare/core/theme/app_text_styles.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/core/theme/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Every test is a widget test on purpose: ThemeData construction makes
  // google_fonts start a font download, and only the widget-test zone
  // (FakeAsync) keeps that from surfacing as an uncaught async error.

  group('AppTheme', () {
    testWidgets('light theme builds with the brand primary and light palette',
        (tester) async {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.primary, const Color(0xFF2A7CF9));
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.extension<AppPalette>(), AppPalette.light);
      expect(theme.textTheme.bodyMedium?.color, AppColors.textPrimary);
      expect(theme.textTheme.bodySmall?.color, AppColors.textSecondary);
      expect(theme.inputDecorationTheme.fillColor, AppColors.inputFill);
    });

    testWidgets(
        'dark theme builds with a recognizable brand blue and dark palette',
        (tester) async {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppPalette.dark.primary);
      expect(theme.colorScheme.primary, const Color(0xFF5B9CFF));
      expect(theme.scaffoldBackgroundColor, AppPalette.dark.background);
      expect(theme.extension<AppPalette>(), AppPalette.dark);
      // Dark text must be light-on-dark, never the light-mode navy.
      expect(theme.textTheme.bodyMedium?.color, AppPalette.dark.textPrimary);
      expect(theme.textTheme.bodyMedium?.color, isNot(AppColors.textPrimary));
      expect(theme.inputDecorationTheme.fillColor, AppPalette.dark.inputFill);
      expect(theme.dialogTheme.backgroundColor, AppPalette.dark.overlay);
      expect(theme.bottomSheetTheme.backgroundColor, AppPalette.dark.overlay);
    });

    testWidgets('both modes define the same component themes', (tester) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        expect(theme.inputDecorationTheme.focusedBorder, isNotNull);
        expect(theme.chipTheme.selectedColor, theme.colorScheme.primary);
        expect(theme.cardTheme.color, theme.extension<AppPalette>()!.surface);
        expect(theme.textSelectionTheme.cursorColor, theme.colorScheme.primary);
        expect(theme.floatingActionButtonTheme.backgroundColor,
            theme.colorScheme.primary);
        expect(theme.progressIndicatorTheme.color, theme.colorScheme.primary);
      }
    });

    testWidgets('AppTextStyles carry no color, so text inherits the theme',
        (tester) async {
      expect(AppTextStyles.h1.color, isNull);
      expect(AppTextStyles.h3.color, isNull);
      expect(AppTextStyles.bodyMedium.color, isNull);
      expect(AppTextStyles.bodySmall.color, isNull);
      expect(AppTextStyles.caption.color, isNull);
    });

    testWidgets('AppPalette lerps between light and dark', (tester) async {
      final mid = AppPalette.light.lerp(AppPalette.dark, 0.5);
      expect(mid.background, isNot(AppPalette.light.background));
      expect(mid.background, isNot(AppPalette.dark.background));
      expect(AppPalette.light.lerp(null, 0.5), AppPalette.light);
    });
  });

  group('Theme-aware text in widgets', () {
    Color? textColor(WidgetTester tester, String text) =>
        tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

    testWidgets('AppTextStyles text resolves to dark textPrimary in dark mode',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: Scaffold(body: Text('hello', style: AppTextStyles.h3)),
      ));
      expect(textColor(tester, 'hello'), AppPalette.dark.textPrimary);
    });

    testWidgets('…and to light textPrimary in light mode', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: Scaffold(body: Text('hello', style: AppTextStyles.h3)),
      ));
      expect(textColor(tester, 'hello'), AppColors.textPrimary);
    });

    testWidgets('context.palette follows the active theme, with a fallback',
        (tester) async {
      late AppPalette seen;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Builder(builder: (context) {
          seen = context.palette;
          return const SizedBox();
        }),
      ));
      expect(seen, AppPalette.dark);

      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          seen = context.palette;
          return const SizedBox();
        }),
      ));
      // Let AnimatedTheme finish the dark → default transition first.
      await tester.pumpAndSettle();
      expect(seen, AppPalette.light, reason: 'no AppTheme → light fallback');
    });
  });

  group('ThemeController persistence (real storage API, mocked platform)', () {
    testWidgets('loads the saved theme', (tester) async {
      FlutterSecureStorage.setMockInitialValues({'app_theme': 'dark'});
      final controller = ThemeController(ThemeMode.system);
      await controller.load();
      expect(controller.value, ThemeMode.dark);
    });

    testWidgets('first launch (nothing saved) → system', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final controller = ThemeController(ThemeMode.system);
      await controller.load();
      expect(controller.value, ThemeMode.system);
    });

    testWidgets('an explicitly saved "system" is honoured too', (tester) async {
      FlutterSecureStorage.setMockInitialValues({'app_theme': 'system'});
      final controller = ThemeController(ThemeMode.dark);
      await controller.load();
      expect(controller.value, ThemeMode.system);
    });

    testWidgets('switching updates listeners immediately and persists',
        (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final controller = ThemeController(ThemeMode.system);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.value, ThemeMode.dark);
      expect(notifications, 1);

      await controller.setThemeMode(ThemeMode.light);
      expect(controller.value, ThemeMode.light);
      expect(notifications, 2);

      // A fresh controller (= app restart) reads the last choice back.
      final restarted = ThemeController(ThemeMode.system);
      await restarted.load();
      expect(restarted.value, ThemeMode.light);

      await controller.setThemeMode(ThemeMode.dark);
      final restartedAgain = ThemeController(ThemeMode.system);
      await restartedAgain.load();
      expect(restartedAgain.value, ThemeMode.dark);
    });

    testWidgets('an unknown stored value falls back to system without throwing',
        (tester) async {
      FlutterSecureStorage.setMockInitialValues({'app_theme': 'purple'});
      final controller = ThemeController(ThemeMode.light);
      await controller.load();
      expect(controller.value, ThemeMode.system);
    });
  });
}
