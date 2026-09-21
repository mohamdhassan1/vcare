// UI Batch 4 — Profile & Settings: grouped sections, 48px photo edit
// target, destructive logout (no chevron, tinted), Settings groups with
// current values, SettingsRadioTile (theme/language), FAQ cards, and
// honest sample-content notices on placeholder screens.

import 'dart:typed_data';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vcare/core/locale/locale_controller.dart';
import 'package:vcare/core/routes/app_router.dart';
import 'package:vcare/core/theme/app_dimensions.dart';
import 'package:vcare/core/theme/app_palette.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/core/theme/theme_controller.dart';
import 'package:vcare/data/models/user_profile_model.dart';
import 'package:vcare/data/repositories/auth_repository.dart';
import 'package:vcare/data/repositories/profile_photo_repository.dart';
import 'package:vcare/data/repositories/user_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/logic/blocs/auth/auth_bloc.dart';
import 'package:vcare/presentation/screans/notifications/notifications_screen.dart';
import 'package:vcare/presentation/screans/profile/faq_screen.dart';
import 'package:vcare/presentation/screans/profile/language_screen.dart';
import 'package:vcare/presentation/screans/profile/medical_records_screen.dart';
import 'package:vcare/presentation/screans/profile/notification_settings_screen.dart';
import 'package:vcare/presentation/screans/profile/payment_screen.dart';
import 'package:vcare/presentation/screans/profile/profile_screen.dart';
import 'package:vcare/presentation/screans/profile/security_screen.dart';
import 'package:vcare/presentation/screans/profile/settings_screen.dart';
import 'package:vcare/presentation/screans/profile/theme_screen.dart';
import 'package:vcare/presentation/widgets/app_card.dart';
import 'package:vcare/presentation/widgets/settings_tiles.dart';

// ---------------------------------------------------------------- fakes

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserProfileModel> getProfile() async => const UserProfileModel(
      name: 'Sara Ahmed', email: 'sara@example.com', phone: '0100');
  @override
  Future<String?> getStoredUsername() async => 'Sara Ahmed';
  @override
  Future<void> updateProfile(
          {required String name,
          required String email,
          required String phone,
          required String gender,
          String? password}) =>
      throw UnimplementedError();
}

class _FakePhotoRepository implements ProfilePhotoRepository {
  @override
  Future<Uint8List?> loadSavedPhoto() async => null;
  @override
  Future<Uint8List?> pickImage(ImageSource source) async => null;
  @override
  Future<void> savePhoto(Uint8List bytes) async {}
  @override
  Future<void> clearPhoto() async {}
}

class _FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;
  @override
  Stream<void> get sessionExpired => const Stream.empty();
  @override
  Future<String> login({required String email, required String password}) =>
      throw UnimplementedError();
  @override
  Future<String> register(
          {required String name,
          required String email,
          required String phone,
          required String gender,
          required String password,
          required String passwordConfirmation}) =>
      throw UnimplementedError();
  @override
  Future<void> logout() async => logoutCalls++;
  @override
  Future<bool> isLoggedIn() async => true;
}

// -------------------------------------------------------------- helpers

final _en = AppLocalizationsEn();
final _ar = AppLocalizationsAr();

Widget _app(Widget home,
    {Locale locale = const Locale('en'),
    ThemeData? theme,
    LocaleController? localeController,
    ThemeController? themeController,
    AuthBloc? authBloc}) {
  final localeCtrl = localeController ?? LocaleController(locale);
  return MultiProvider(
    providers: [
      ListenableProvider<LocaleController>.value(value: localeCtrl),
      ListenableProvider<ThemeController>.value(
          value: themeController ?? ThemeController(ThemeMode.light)),
      RepositoryProvider<UserRepository>(create: (_) => _FakeUserRepository()),
      RepositoryProvider<ProfilePhotoRepository>(
          create: (_) => _FakePhotoRepository()),
      if (authBloc != null) BlocProvider<AuthBloc>.value(value: authBloc),
    ],
    child: ValueListenableBuilder<Locale>(
      valueListenable: localeCtrl,
      builder: (context, current, _) => MaterialApp(
        locale: current,
        theme: theme ?? AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRouter.generateRoute,
        home: home,
      ),
    ),
  );
}

void _useWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('Profile (H10)', () {
    late AuthBloc authBloc;
    late _FakeAuthRepository auth;

    setUp(() {
      auth = _FakeAuthRepository();
      authBloc = AuthBloc(auth);
    });
    tearDown(() => authBloc.close());

    testWidgets(
        'real data, grouped sections, 48px photo edit target, '
        'logout is destructive without a chevron', (tester) async {
      await tester.pumpWidget(_app(const ProfileScreen(), authBloc: authBloc));
      await tester.pumpAndSettle();

      expect(find.text('Sara Ahmed'), findsOneWidget);
      expect(find.text('sara@example.com'), findsOneWidget);
      expect(find.byType(SettingsGroup), findsNWidgets(2));
      expect(find.text(_en.accountSection), findsOneWidget);
      // Photo edit target (top of the page).
      final edit = tester.getSize(find.ancestor(
          of: find.byIcon(Icons.camera_alt_rounded),
          matching: find.byType(InkResponse)));
      expect(edit.width, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      expect(edit.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      expect(find.byTooltip(_en.changePhoto), findsOneWidget);

      // The list is lazy: bring the bottom (logout) into view first.
      await tester.scrollUntilVisible(find.byType(DestructiveTile), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsRow), findsNWidgets(5));

      // Logout: no chevron inside the destructive tile, error-colored text.
      final logout = find.byType(DestructiveTile);
      expect(logout, findsOneWidget);
      expect(
          find.descendant(
              of: logout, matching: find.byIcon(Icons.chevron_right_rounded)),
          findsNothing);
      final label = tester.widget<Text>(
          find.descendant(of: logout, matching: find.text(_en.logout)));
      expect(label.style?.color, AppPalette.light.error);
      final tileSize = tester.getSize(logout);
      expect(
          tileSize.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));

      // Existing confirmation flow still runs.
      await tester.ensureVisible(logout);
      await tester.tap(logout);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text(_en.cancel));
      await tester.pumpAndSettle();
      expect(auth.logoutCalls, 0);
    });

    testWidgets('photo edit opens the existing options sheet', (tester) async {
      await tester.pumpWidget(_app(const ProfileScreen(), authBloc: authBloc));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(_en.changePhoto));
      await tester.pumpAndSettle();
      expect(find.text(_en.updateProfilePhoto), findsOneWidget);
      expect(find.text(_en.chooseFromGallery), findsOneWidget);
      expect(find.text(_en.removePhoto), findsNothing, reason: 'no photo yet');
    });

    testWidgets('Arabic RTL: chevrons point left, no overflow at 320px',
        (tester) async {
      _useWidth(tester, 320);
      await tester.pumpWidget(_app(const ProfileScreen(),
          locale: const Locale('ar'), authBloc: authBloc));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.chevron_left_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.text(_ar.logout), findsOneWidget);
    });
  });

  group('Settings (H10)', () {
    late AuthBloc authBloc;
    setUp(() => authBloc = AuthBloc(_FakeAuthRepository()));
    tearDown(() => authBloc.close());

    testWidgets('groups with current language/theme, logout not a nav row',
        (tester) async {
      await tester.pumpWidget(_app(const SettingsScreen(),
          authBloc: authBloc,
          themeController: ThemeController(ThemeMode.dark)));
      await tester.pumpAndSettle();
      expect(find.text(_en.preferencesSection), findsOneWidget);
      expect(find.text(_en.supportSection), findsOneWidget);
      expect(find.text('English'), findsOneWidget, reason: 'current language');
      expect(find.text(_en.dark), findsOneWidget, reason: 'current theme');
      expect(find.byType(SettingsRow), findsNWidgets(5));
      expect(find.byType(DestructiveTile), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(5));

      await tester.tap(find.text(_en.theme));
      await tester.pumpAndSettle();
      expect(find.byType(ThemeScreen), findsOneWidget);
    });
  });

  group('Theme + Language (M6)', () {
    testWidgets(
        'SettingsRadioTile: selected has check + bold + semantics; '
        'tapping switches the controller', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = ThemeController(ThemeMode.system);
      await tester
          .pumpWidget(_app(const ThemeScreen(), themeController: controller));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsRadioTile), findsNWidgets(3));
      expect(find.text(_en.systemDefaultHint), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final system = tester.getSemantics(find
          .bySemanticsLabel('${_en.systemDefault}, ${_en.systemDefaultHint}'));
      expect(system.flagsCollection.isSelected, Tristate.isTrue);
      final systemTitle = tester.widget<Text>(find.text(_en.systemDefault));
      expect(systemTitle.style?.fontWeight, FontWeight.w700);
      final lightTitle = tester.widget<Text>(find.text(_en.light));
      expect(lightTitle.style?.fontWeight, isNot(FontWeight.w700));

      await tester.tap(find.text(_en.dark));
      await tester.pumpAndSettle();
      expect(controller.value, ThemeMode.dark);
      final darkTitle = tester.widget<Text>(find.text(_en.dark));
      expect(darkTitle.style?.fontWeight, FontWeight.w700);
      final tile = tester.getSize(find.byType(SettingsRadioTile).first);
      expect(tile.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      handle.dispose();
    });

    testWidgets('Language screen switches the locale in place', (tester) async {
      final controller = LocaleController(const Locale('en'));
      await tester.pumpWidget(
          _app(const LanguageScreen(), localeController: controller));
      await tester.pumpAndSettle();
      expect(find.text(_en.language), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(controller.value.languageCode, 'ar');
      expect(find.text(_ar.language), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(LanguageScreen))),
          TextDirection.rtl);
    });
  });

  group('FAQ (P4)', () {
    testWidgets('cards expand with a bold question and visible answer',
        (tester) async {
      await tester.pumpWidget(_app(const FaqScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AppCard), findsNWidgets(3));
      expect(find.byType(ExpansionTile), findsNWidgets(3));
      expect(find.text(_en.faqA1), findsNothing);

      await tester.tap(find.text(_en.faqQ1));
      await tester.pumpAndSettle();
      expect(find.text(_en.faqA1), findsOneWidget);
      final q = tester.widget<AnimatedDefaultTextStyle>(find
          .ancestor(
              of: find.text(_en.faqQ1),
              matching: find.byType(AnimatedDefaultTextStyle))
          .first);
      expect(q.style.fontWeight, FontWeight.w700);
    });
  });

  group('Placeholder screens (M10)', () {
    testWidgets(
        'sample-content notice on illustrative screens; payment '
        'keeps its per-row "Not connected"', (tester) async {
      for (final screen in <Widget>[
        const NotificationsScreen(),
        const MedicalRecordsScreen(),
        const NotificationSettingsScreen(),
        const SecurityScreen(),
      ]) {
        await tester.pumpWidget(_app(screen));
        await tester.pumpAndSettle();
        expect(find.text(_en.sampleContentNotice), findsOneWidget,
            reason: '$screen');
        expect(find.byType(AppCard), findsWidgets, reason: '$screen');
      }
      await tester.pumpWidget(_app(const PaymentScreen()));
      await tester.pumpAndSettle();
      expect(find.text(_en.notConnected), findsNWidgets(4));
      expect(find.text(_en.sampleContentNotice), findsNothing);
    });

    testWidgets('Arabic notice, no overflow at 320px', (tester) async {
      _useWidth(tester, 320);
      for (final screen in <Widget>[
        const NotificationsScreen(),
        const MedicalRecordsScreen(),
        const PaymentScreen(),
        const SettingsScreen(),
        const ThemeScreen(),
        const FaqScreen(),
      ]) {
        await tester.pumpWidget(_app(screen, locale: const Locale('ar')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$screen');
      }
      expect(find.text(_ar.faq), findsOneWidget);
    });
  });

  group('Responsive', () {
    testWidgets('profile content is capped on a wide window', (tester) async {
      _useWidth(tester, 1400);
      final authBloc = AuthBloc(_FakeAuthRepository());
      addTearDown(authBloc.close);
      await tester.pumpWidget(_app(const ProfileScreen(), authBloc: authBloc));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(ListView)).width,
          AppDimensions.contentMaxWidth);
    });
  });
}
