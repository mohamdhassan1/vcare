// Phase 3 — localization: ARB completeness, generated locales, RTL/LTR
// directionality, live locale switching (no restart, navigation kept),
// persistence, and localized error text.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/core/locale/locale_controller.dart';
import 'package:vcare/core/theme/app_text_styles.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/l10n/l10n.dart';

Map<String, dynamic> _readArb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Message keys only (no "@key" metadata, no "@@locale").
Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// `{name}` placeholders used inside a message (ICU plural/select
/// bodies included), so both languages must use the same set.
Set<String> _placeholders(String message) => RegExp(r'\{([A-Za-z0-9_]+)\}')
    .allMatches(message)
    .map((m) => m.group(1)!)
    .toSet();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ARB files', () {
    final en = _readArb('app_en.arb');
    final ar = _readArb('app_ar.arb');

    test('both parse as JSON with matching locale tags', () {
      expect(en['@@locale'], 'en');
      expect(ar['@@locale'], 'ar');
    });

    test('Arabic has every English key and no extras', () {
      final enKeys = _messageKeys(en);
      final arKeys = _messageKeys(ar);
      expect(arKeys.difference(enKeys), isEmpty, reason: 'extra Arabic keys');
      expect(enKeys.difference(arKeys), isEmpty, reason: 'missing Arabic keys');
    });

    test('no empty translations', () {
      for (final key in _messageKeys(en)) {
        expect((en[key] as String).trim(), isNotEmpty, reason: 'en.$key');
        expect((ar[key] as String).trim(), isNotEmpty, reason: 'ar.$key');
      }
    });

    test('placeholders match between English and Arabic', () {
      for (final key in _messageKeys(en)) {
        expect(
            _placeholders(ar[key] as String), _placeholders(en[key] as String),
            reason: 'placeholders differ for "$key"');
      }
    });

    test('required keys exist', () {
      const required = [
        'retry',
        'cancel',
        'save',
        'done',
        'logout',
        'settings',
        'search',
        'myFavorites',
        'myAppointment',
        'bookAppointment',
        'removePhoto',
        'sessionExpired',
        'somethingWentWrong',
        'theme',
        'language',
        'light',
        'dark',
        'systemDefault',
        'aiAssistantTitle',
        'errorNetwork',
        'emailRequired',
        'emailInvalid',
        'passwordsDoNotMatch',
        'homeGreeting',
      ];
      for (final key in required) {
        expect(en.containsKey(key), isTrue, reason: 'en missing $key');
        expect(ar.containsKey(key), isTrue, reason: 'ar missing $key');
      }
    });
  });

  group('Generated localizations', () {
    test('English and Arabic load and differ', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.localeName, 'en');
      expect(ar.localeName, 'ar');
      expect(en.login, 'Login');
      expect(ar.login, isNot('Login'));
      expect(ar.login, isNotEmpty);
      expect(en.homeGreeting('Sara'), 'Hi, Sara!');
      expect(ar.homeGreeting('Sara'), contains('Sara'));
      expect(en.resultsFound(0), 'No results');
      expect(en.resultsFound(1), '1 result found');
      expect(en.resultsFound(5), '5 results found');
      expect(ar.resultsFound(2), isNotEmpty);
      expect(en.passwordTooShort(6), contains('6'));
    });

    test('brand name is the same in both languages (intentional)', () {
      expect(AppLocalizationsEn().appTitle, AppLocalizationsAr().appTitle);
    });
  });

  group('Directionality', () {
    Widget app(Locale locale) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: AppBar(
                title:
                    Builder(builder: (context) => Text(context.l10n.settings))),
            body: Builder(
                builder: (context) =>
                    Text(context.isRtl ? 'rtl' : 'ltr', key: const Key('dir'))),
          ),
        );

    testWidgets('Arabic lays out right-to-left with Arabic text',
        (tester) async {
      await tester.pumpWidget(app(const Locale('ar')));
      await tester.pumpAndSettle();
      expect(Directionality.of(tester.element(find.byKey(const Key('dir')))),
          TextDirection.rtl);
      expect(find.text('rtl'), findsOneWidget);
      expect(find.text(AppLocalizationsAr().settings), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('English lays out left-to-right', (tester) async {
      await tester.pumpWidget(app(const Locale('en')));
      await tester.pumpAndSettle();
      expect(Directionality.of(tester.element(find.byKey(const Key('dir')))),
          TextDirection.ltr);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('Live locale switching (same wiring as main.dart)', () {
    /// Mirrors VCareApp: a LocaleController above MaterialApp, watched
    /// by a Builder so the app re-renders in place when it changes.
    Widget app(LocaleController controller) =>
        ListenableProvider<LocaleController>.value(
          value: controller,
          child: Builder(builder: (context) {
            final locale = context.watch<LocaleController>().value;
            return MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Column(children: [
                    Text(context.l10n.settings),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  Scaffold(body: Text(context.l10n.profile)))),
                      child: const Text('go'),
                    ),
                  ]),
                ),
              ),
            );
          }),
        );

    testWidgets('English → Arabic → English updates in place, no restart',
        (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final controller = LocaleController(const Locale('en'));
      await tester.pumpWidget(app(controller));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      await controller.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();
      expect(find.text(AppLocalizationsAr().settings), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(Directionality.of(tester.element(find.text('go'))),
          TextDirection.rtl);

      await controller.setLocale(const Locale('en'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('go'))),
          TextDirection.ltr);
    });

    testWidgets('switching keeps the navigation stack', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final controller = LocaleController(const Locale('en'));
      await tester.pumpWidget(app(controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);

      await controller.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();
      // Still on the pushed page, now in Arabic.
      expect(find.text(AppLocalizationsAr().profile), findsOneWidget);
      expect(find.text('go'), findsNothing);
    });
  });

  group('LocaleController persistence (real storage API, mocked platform)', () {
    testWidgets('restores the saved locale', (tester) async {
      FlutterSecureStorage.setMockInitialValues({'app_locale': 'ar'});
      final controller = LocaleController(const Locale('en'));
      await controller.load();
      expect(controller.value, const Locale('ar'));
    });

    testWidgets('nothing saved → keeps the default', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final controller = LocaleController(const Locale('en'));
      await controller.load();
      expect(controller.value, const Locale('en'));
    });

    testWidgets('setLocale persists so a restart reads it back',
        (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final controller = LocaleController(const Locale('en'));
      await controller.setLocale(const Locale('ar'));

      final restarted = LocaleController(const Locale('en'));
      await restarted.load();
      expect(restarted.value, const Locale('ar'));

      await controller.setLocale(const Locale('en'));
      final restartedAgain = LocaleController(const Locale('ar'));
      await restartedAgain.load();
      expect(restartedAgain.value, const Locale('en'));
    });
  });

  group('Localized error text', () {
    Future<BuildContext> contextFor(WidgetTester tester, Locale locale) async {
      late BuildContext captured;
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          captured = context;
          return const SizedBox();
        }),
      ));
      await tester.pumpAndSettle();
      return captured;
    }

    testWidgets('known codes are localized in both languages', (tester) async {
      const network = AppErrorInfo(AppErrorCode.network, 'No internet.');
      final en = await contextFor(tester, const Locale('en'));
      expect(en.errorText(network), AppLocalizationsEn().errorNetwork);
      final ar = await contextFor(tester, const Locale('ar'));
      expect(ar.errorText(network), AppLocalizationsAr().errorNetwork);
      expect(ar.errorText(network), isNot(contains('internet')));
    });

    testWidgets('backend validation text is shown as-is, never translated',
        (tester) async {
      const fromServer = AppErrorInfo(
          AppErrorCode.validation, 'The email has already been taken.',
          serverMessage: 'The email has already been taken.');
      final ar = await contextFor(tester, const Locale('ar'));
      expect(ar.errorText(fromServer), 'The email has already been taken.');
    });

    testWidgets(
        'unknown without server text → generic message; '
        '401 on sign-in → invalid credentials', (tester) async {
      final en = await contextFor(tester, const Locale('en'));
      expect(en.errorText(AppErrorInfo.unknown),
          AppLocalizationsEn().somethingWentWrong);
      const unauthorized =
          AppErrorInfo(AppErrorCode.unauthorized, 'Session expired.');
      expect(en.errorText(unauthorized), AppLocalizationsEn().sessionExpired);
      expect(en.errorText(unauthorized, invalidCredentials: true),
          AppLocalizationsEn().invalidCredentials);
    });
  });
  group('Arabic font configuration (bundled Tajawal fallback)', () {
    testWidgets('the Arabic font is bundled and registered in the app',
        (tester) async {
      // pubspec.yaml `fonts:` → generated FontManifest.json in the bundle.
      final manifest = await rootBundle.loadString('FontManifest.json');
      expect(manifest, contains(AppTextStyles.arabicFontFamily));
      for (final file in const [
        'assets/fonts/Tajawal-Regular.ttf',
        'assets/fonts/Tajawal-Medium.ttf',
        'assets/fonts/Tajawal-Bold.ttf',
      ]) {
        expect(File(file).existsSync(), isTrue, reason: '$file missing');
      }
    });

    testWidgets('every text style and theme slot falls back to it',
        (tester) async {
      for (final style in [
        AppTextStyles.h1,
        AppTextStyles.h3,
        AppTextStyles.bodyMedium,
        AppTextStyles.bodySmall,
        AppTextStyles.caption,
        AppTextStyles.button,
      ]) {
        expect(
            style.fontFamilyFallback, contains(AppTextStyles.arabicFontFamily));
      }
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        expect(theme.textTheme.bodyMedium!.fontFamilyFallback,
            contains(AppTextStyles.arabicFontFamily));
        // A slot AppTheme never sets explicitly still gets the fallback.
        expect(theme.textTheme.displayLarge!.fontFamilyFallback,
            contains(AppTextStyles.arabicFontFamily));
        expect(theme.inputDecorationTheme.hintStyle!.fontFamilyFallback,
            contains(AppTextStyles.arabicFontFamily));
      }
    });
  });
}
