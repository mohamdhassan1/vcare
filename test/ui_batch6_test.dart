// UI Batch 6 — pre-auth: splash entrance, onboarding layout, sign-in /
// sign-up / forgot-password forms (labels, password toggle, gender
// tiles, loading, honest reset note), RTL, narrow widths, dark mode.
// Auth API/BLoC behavior is covered by the existing forms/auth tests.

import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/routes/app_router.dart';
import 'package:vcare/core/routes/app_routes.dart';
import 'package:vcare/core/theme/app_dimensions.dart';
import 'package:vcare/core/theme/app_palette.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/data/repositories/auth_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/logic/blocs/auth/auth_bloc.dart';
import 'package:vcare/presentation/screans/auth/forgot_password_screen.dart';
import 'package:vcare/presentation/screans/auth/sign_in_screen.dart';
import 'package:vcare/presentation/screans/auth/sign_up_screen.dart';
import 'package:vcare/presentation/screans/onboarding/onboarding_screen.dart';
import 'package:vcare/presentation/screans/splash/splash_screen.dart';
import 'package:vcare/presentation/widgets/brand_lockup.dart';
import 'package:vcare/presentation/widgets/content_constraint.dart';
import 'package:vcare/presentation/widgets/gender_selector.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';

// ---------------------------------------------------------------- fakes

class _FakeAuthRepository implements AuthRepository {
  int loginCalls = 0;
  int registerCalls = 0;
  String? lastGender;
  Completer<String>? pending;
  bool loggedIn = false;

  @override
  Stream<void> get sessionExpired => const Stream.empty();

  @override
  Future<String> login({required String email, required String password}) {
    loginCalls++;
    pending = Completer<String>();
    return pending!.future;
  }

  @override
  Future<String> register(
      {required String name,
      required String email,
      required String phone,
      required String gender,
      required String password,
      required String passwordConfirmation}) {
    registerCalls++;
    lastGender = gender;
    pending = Completer<String>();
    return pending!.future;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isLoggedIn() async => loggedIn;
}

// -------------------------------------------------------------- helpers

final _en = AppLocalizationsEn();
final _ar = AppLocalizationsAr();

Widget _app(Widget home, _FakeAuthRepository auth,
        {Locale locale = const Locale('en'),
        ThemeData? theme,
        bool reduceMotion = false,
        bool stubRoutes = false}) =>
    RepositoryProvider<AuthRepository>.value(
      value: auth,
      child: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(auth),
        child: MaterialApp(
          locale: locale,
          theme: theme ?? AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // stubRoutes: render the route name instead of the real screen
          // (the home shell needs every app bloc).
          onGenerateRoute: stubRoutes
              ? (settings) => MaterialPageRoute(
                  builder: (_) => Text('route:${settings.name}'))
              : AppRouter.generateRoute,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
          home: home,
        ),
      ),
    );

void _useWidth(WidgetTester tester, double width, [double height = 800]) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _labelOf(String label) => find.widgetWithText(TextFormField, label);

void main() {
  late _FakeAuthRepository auth;
  setUp(() => auth = _FakeAuthRepository());

  group('Splash', () {
    testWidgets(
        'branded lockup fades in, then the existing decision runs '
        '(logged out → onboarding)', (tester) async {
      await tester.pumpWidget(_app(const SplashScreen(), auth));
      await tester.pump();
      expect(find.text(_en.appTitle), findsOneWidget);
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('logged in → home route; static under reduced motion',
        (tester) async {
      auth.loggedIn = true;
      await tester.pumpWidget(_app(const SplashScreen(), auth,
          reduceMotion: true, stubRoutes: true));
      await tester.pump();
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      // Route decision unchanged: /home is requested.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('route:${AppRoutes.home}'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });

  group('Onboarding', () {
    testWidgets('content, PrimaryButton CTA, Get Started → Sign In',
        (tester) async {
      await tester.pumpWidget(_app(const OnboardingScreen(), auth));
      await tester.pumpAndSettle();
      expect(find.byType(BrandLockup), findsOneWidget);
      expect(find.text(_en.onboardingHeadline), findsOneWidget);
      expect(find.text(_en.onboardingSubtitle), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(tester.getSize(find.byType(PrimaryButton)).height,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      await tester.tap(find.text(_en.getStarted));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('no overflow at 320px (EN/AR); brand stays LTR in RTL',
        (tester) async {
      _useWidth(tester, 320, 560);
      for (final locale in const [Locale('en'), Locale('ar')]) {
        await tester
            .pumpWidget(_app(const OnboardingScreen(), auth, locale: locale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$locale');
      }
      final lockupRow = tester.widget<Row>(find.descendant(
          of: find.byType(BrandLockup), matching: find.byType(Row)));
      expect(lockupRow.textDirection, TextDirection.ltr);
      expect(find.text(_ar.getStarted), findsOneWidget);
    });

    testWidgets('wide window: content is constrained', (tester) async {
      _useWidth(tester, 1400, 900);
      await tester.pumpWidget(_app(const OnboardingScreen(), auth));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(PrimaryButton)).width,
          lessThanOrEqualTo(520));
    });
  });

  group('Sign In', () {
    testWidgets(
        'labels, password toggle with localized tooltip, CTA, '
        'links ≥48px', (tester) async {
      await tester.pumpWidget(_app(const SignInScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.byType(BrandLockup), findsOneWidget);
      expect(find.text(_en.welcomeBack), findsOneWidget);
      expect(_labelOf(_en.email), findsOneWidget);
      expect(_labelOf(_en.password), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);

      // Password toggle.
      expect(find.byTooltip(_en.showPassword), findsOneWidget);
      final toggle = find.ancestor(
          of: find.byTooltip(_en.showPassword),
          matching: find.byType(IconButton));
      expect(tester.getSize(toggle).width,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      await tester.enterText(_labelOf(_en.password), 'secret1');
      expect(
          tester
              .widget<EditableText>(find.descendant(
                  of: _labelOf(_en.password),
                  matching: find.byType(EditableText)))
              .obscureText,
          isTrue);
      await tester.tap(toggle);
      await tester.pump();
      expect(find.byTooltip(_en.hidePassword), findsOneWidget);
      expect(
          tester
              .widget<EditableText>(find.descendant(
                  of: _labelOf(_en.password),
                  matching: find.byType(EditableText)))
              .obscureText,
          isFalse);

      // CTA and links.
      expect(find.byType(PrimaryButton), findsOneWidget);
      final forgot =
          find.widgetWithText(TextButton, _en.forgotPasswordQuestion);
      expect(tester.getSize(forgot).height,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      await tester.tap(forgot);
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets(
        'validation messages show under the fields; loading state '
        'uses the button spinner once and blocks duplicates', (tester) async {
      await tester.pumpWidget(_app(const SignInScreen(), auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.login));
      await tester.pump();
      expect(find.text(_en.emailRequired), findsOneWidget);
      expect(find.text(_en.passwordRequired), findsOneWidget);
      expect(auth.loginCalls, 0);

      await tester.enterText(_labelOf(_en.email), 'a@b.com');
      await tester.enterText(_labelOf(_en.password), 'secret1');
      await tester.tap(find.text(_en.login));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(auth.loginCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget,
          reason: 'one spinner, in the button');
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(
          tester
              .widget<TextButton>(
                  find.widgetWithText(TextButton, _en.noAccountSignUp))
              .onPressed,
          isNull,
          reason: 'no navigating away mid-request');

      auth.pending!.completeError(Exception('end'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Arabic RTL and dark mode render, no overflow at 320px',
        (tester) async {
      _useWidth(tester, 320, 560);
      await tester.pumpWidget(_app(const SignInScreen(), auth,
          locale: const Locale('ar'), theme: AppTheme.dark));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(_ar.welcomeBack), findsOneWidget);
      expect(_labelOf(_ar.email), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(SignInScreen))),
          TextDirection.rtl);
      // Long Arabic validation message wraps rather than overflowing.
      await tester.tap(find.text(_ar.login));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text(_ar.emailRequired), findsOneWidget);
    });
  });

  group('Sign Up', () {
    testWidgets(
        'all fields, gender tiles with selected semantics, '
        'confirm-password validation, unchanged gender values', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const SignUpScreen(), auth));
      await tester.pumpAndSettle();

      for (final label in [
        _en.fullName,
        _en.email,
        _en.phoneNumber,
        _en.password,
        _en.confirmPassword
      ]) {
        expect(_labelOf(label), findsOneWidget, reason: label);
      }
      expect(find.text(_en.gender), findsOneWidget);
      expect(find.byType(GenderSelector), findsOneWidget);
      expect(find.byType(RadioListTile<String>), findsNothing);

      // Male preselected: check badge + bold + selected semantics.
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      final male = tester.getSemantics(find.bySemanticsLabel(_en.male));
      expect(male.flagsCollection.isSelected, Tristate.isTrue);
      final maleText = tester.widget<Text>(find.text(_en.male));
      expect(maleText.style?.fontWeight, FontWeight.w700);
      final tile = tester.getSize(find.ancestor(
          of: find.text(_en.female), matching: find.byType(InkWell)));
      expect(tile.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));

      await tester.tap(find.text(_en.female));
      await tester.pumpAndSettle();
      final female = tester.getSemantics(find.bySemanticsLabel(_en.female));
      expect(female.flagsCollection.isSelected, Tristate.isTrue);
      handle.dispose();

      // Fill the form with a mismatching confirmation.
      await tester.enterText(_labelOf(_en.fullName), 'Sara');
      await tester.enterText(_labelOf(_en.email), 'sara@example.com');
      await tester.enterText(_labelOf(_en.phoneNumber), '0100');
      await tester.enterText(_labelOf(_en.password), 'secret1');
      await tester.enterText(_labelOf(_en.confirmPassword), 'secret2');
      await tester.ensureVisible(find.text(_en.createAccount).last);
      await tester.tap(find.widgetWithText(ElevatedButton, _en.createAccount));
      await tester.pump();
      expect(find.text(_en.passwordsDoNotMatch), findsOneWidget);
      expect(auth.registerCalls, 0);

      await tester.enterText(_labelOf(_en.confirmPassword), 'secret1');
      await tester.tap(find.widgetWithText(ElevatedButton, _en.createAccount));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(auth.registerCalls, 1);
      expect(auth.lastGender, '1', reason: 'female still maps to "1"');
      auth.pending!.completeError(Exception('end'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('no overflow at 320px in Arabic, dark mode', (tester) async {
      _useWidth(tester, 320, 560);
      await tester.pumpWidget(_app(const SignUpScreen(), auth,
          locale: const Locale('ar'), theme: AppTheme.dark));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(_ar.male), findsOneWidget);
      expect(find.text(_ar.female), findsOneWidget);
      // Selected tile uses the dark palette tint.
      final selected = tester.widget<AnimatedContainer>(find
          .ancestor(
              of: find.text(_ar.male), matching: find.byType(AnimatedContainer))
          .first);
      expect((selected.decoration as BoxDecoration).color,
          AppPalette.dark.primaryLight);
    });
  });

  group('Forgot Password', () {
    testWidgets(
        'honest note up front; submitting only shows the same '
        'message; nothing is sent', (tester) async {
      await tester.pumpWidget(_app(const ForgotPasswordScreen(), auth));
      await tester.pumpAndSettle();
      expect(find.byType(ContentConstraint), findsOneWidget);
      expect(find.text(_en.passwordResetUnavailable), findsOneWidget);
      expect(_labelOf(_en.email), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);

      await tester.enterText(_labelOf(_en.email), 'a@b.com');
      await tester.tap(find.text(_en.resetPassword));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(_en.passwordResetUnavailable), findsNWidgets(2),
          reason: 'note + snackbar, no success claim');
      expect(auth.loginCalls + auth.registerCalls, 0);
    });

    testWidgets('Arabic, 320px, no overflow', (tester) async {
      _useWidth(tester, 320, 560);
      await tester.pumpWidget(
          _app(const ForgotPasswordScreen(), auth, locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(_ar.passwordResetUnavailable), findsOneWidget);
    });
  });

  // Regression: the app must start with a single route. With the default
  // initial-route rule, "/" was pushed under "/splash", so the shell that
  // later replaced Splash could pop back to the router's error page.
  testWidgets('the initial stack is only Splash (no phantom "/" underneath)',
      (tester) async {
    for (final name in ['/', AppRoutes.splash]) {
      final routes = AppRouter.generateInitialRoutes(name);
      expect(routes, hasLength(1), reason: name);
      expect(routes.single.settings.name, AppRoutes.splash, reason: name);
    }
    await tester.pumpWidget(RepositoryProvider<AuthRepository>.value(
      value: auth,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.splash,
        onGenerateInitialRoutes: AppRouter.generateInitialRoutes,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    ));
    await tester.pump();
    expect(find.text(_en.pageCouldNotOpen), findsNothing);
    expect(Navigator.of(tester.element(find.byType(SplashScreen))).canPop(),
        isFalse);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    // Splash replaced itself: Onboarding is the root, nothing to pop to.
    expect(Navigator.of(tester.element(find.byType(OnboardingScreen))).canPop(),
        isFalse);
  });

  testWidgets('routes between the pre-auth screens are unchanged',
      (tester) async {
    await tester.pumpWidget(_app(const SignInScreen(), auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.noAccountSignUp));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
    await tester.ensureVisible(find.text(_en.haveAccountSignIn));
    await tester.tap(find.text(_en.haveAccountSignIn));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(AppRoutes.signIn, '/sign-in');
  });
}
