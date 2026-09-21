// B9 — forms scroll instead of overflowing on small screens.
// B15 — the keyboard's Done/Enter on Sign In submits through the same
// validated path as the button, with no duplicate submissions.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/data/models/specialization_model.dart';
import 'package:vcare/data/models/user_profile_model.dart';
import 'package:vcare/data/repositories/auth_repository.dart';
import 'package:vcare/data/repositories/doctor_repository.dart';
import 'package:vcare/data/repositories/profile_photo_repository.dart';
import 'package:vcare/data/repositories/specialization_repository.dart';
import 'package:vcare/data/repositories/user_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/logic/blocs/auth/auth_bloc.dart';
import 'package:vcare/logic/blocs/home/home_bloc.dart';
import 'package:vcare/logic/blocs/profile/profile_bloc.dart';
import 'package:vcare/logic/blocs/profile/profile_event.dart';
import 'package:vcare/presentation/screans/auth/forgot_password_screen.dart';
import 'package:vcare/presentation/screans/auth/sign_in_screen.dart';
import 'package:vcare/presentation/screans/profile/personal_information_screen.dart';
import 'package:vcare/presentation/widgets/gender_selector.dart';

// ---------------------------------------------------------------- fakes

class _FakeAuthRepository implements AuthRepository {
  int loginCalls = 0;
  Completer<String>? pendingLogin;

  @override
  Stream<void> get sessionExpired => const Stream.empty();

  @override
  Future<String> login({required String email, required String password}) {
    loginCalls++;
    pendingLogin = Completer<String>();
    return pendingLogin!.future; // stays "loading" until completed
  }

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
  Future<void> logout() async {}

  @override
  Future<bool> isLoggedIn() async => false;
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserProfileModel> getProfile() async => const UserProfileModel(
      name: 'Mohamed', email: 'm@example.com', phone: '0100', gender: '1');

  @override
  Future<String?> getStoredUsername() async => 'Mohamed';

  @override
  Future<void> updateProfile(
          {required String name,
          required String email,
          required String phone,
          required String gender,
          String? password}) async =>
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

class _FakeSpecializationRepository implements SpecializationRepository {
  @override
  Future<List<SpecializationModel>> getSpecializations() async => const [];
}

class _FakeDoctorRepository implements DoctorRepository {
  @override
  Future<List<DoctorModel>> getDoctors() async => const [];
  @override
  Future<DoctorModel> getDoctorDetails(int id) => throw UnimplementedError();
  @override
  Future<List<DoctorModel>> searchDoctors(String name) async => const [];
}

// -------------------------------------------------------------- helpers

/// A phone-sized viewport with the keyboard taking most of it — the
/// situation that used to overflow the fixed-height forms.
void useSmallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 420);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  group('Sign In (B9 + B15)', () {
    late _FakeAuthRepository auth;

    Widget signIn() => wrap(BlocProvider(
        create: (_) => AuthBloc(auth), child: const SignInScreen()));

    setUp(() => auth = _FakeAuthRepository());

    testWidgets(
        'lays out without overflow on a small screen and the '
        'Login button can be scrolled to', (tester) async {
      useSmallViewport(tester);
      await tester.pumpWidget(signIn());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Login'), 50,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Done on the password field submits once via validation',
        (tester) async {
      await tester.pumpWidget(signIn());
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'john@example.com');
      await tester.enterText(fields.at(1), 'secret1');
      await tester.tap(fields.at(1));
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(auth.loginCalls, 1, reason: 'Enter submits through _submit');

      // Still loading (login future pending): Enter again must not
      // queue a second request.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(auth.loginCalls, 1);

      auth.pendingLogin!.completeError(Exception('end test'));
      await tester.pump();
    });

    testWidgets('Done with an invalid email does not submit', (tester) async {
      await tester.pumpWidget(signIn());
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'abc@example');
      await tester.enterText(fields.at(1), 'secret1');
      await tester.tap(fields.at(1));
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(auth.loginCalls, 0);
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('email field advances with "next", password uses "done"',
        (tester) async {
      await tester.pumpWidget(signIn());
      await tester.pump();

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.elementAt(0).textInputAction, TextInputAction.next);
      expect(textFields.elementAt(1).textInputAction, TextInputAction.done);
    });
  });

  testWidgets('Forgot Password scrolls on a small screen (B9)', (tester) async {
    useSmallViewport(tester);
    await tester.pumpWidget(wrap(const ForgotPasswordScreen()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Reset Password'), 50,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Reset Password'), findsOneWidget);
  });

  testWidgets('Personal Information scrolls on a small screen (B9)',
      (tester) async {
    useSmallViewport(tester);
    final userRepo = _FakeUserRepository();
    final profileBloc = ProfileBloc(userRepo, _FakePhotoRepository())
      ..add(const ProfileStarted());
    final homeBloc = HomeBloc(
        userRepo, _FakeSpecializationRepository(), _FakeDoctorRepository());
    addTearDown(profileBloc.close);
    addTearDown(homeBloc.close);

    await tester.pumpWidget(wrap(RepositoryProvider<UserRepository>.value(
      value: userRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>.value(value: profileBloc),
          BlocProvider<HomeBloc>.value(value: homeBloc),
        ],
        child: const PersonalInformationScreen(),
      ),
    )));
    await tester.pump(); // ProfileLoaded → prefill
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Mohamed'), findsOneWidget, reason: 'prefilled name');
    await tester.scrollUntilVisible(find.text('Save'), 50,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Save'), findsOneWidget);
  });

  // Batch 7 — Personal Information uses the same labelled fields and
  // gender tiles as Sign Up; the prefilled gender ("1" → Female) shows
  // as the selected tile and switching keeps the "0"/"1" values.
  testWidgets('Personal Information prefills the gender tile', (tester) async {
    final userRepo = _FakeUserRepository();
    final profileBloc = ProfileBloc(userRepo, _FakePhotoRepository())
      ..add(const ProfileStarted());
    final homeBloc = HomeBloc(
        userRepo, _FakeSpecializationRepository(), _FakeDoctorRepository());
    addTearDown(profileBloc.close);
    addTearDown(homeBloc.close);

    await tester.pumpWidget(wrap(RepositoryProvider<UserRepository>.value(
      value: userRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>.value(value: profileBloc),
          BlocProvider<HomeBloc>.value(value: homeBloc),
        ],
        child: const PersonalInformationScreen(),
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.byType(GenderSelector), findsOneWidget);
    expect(find.byType(RadioListTile<String>), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
    // Fake profile gender is "1" → Female tile carries the check badge.
    final femaleTile =
        find.ancestor(of: find.text('Female'), matching: find.byType(InkWell));
    expect(
        find.descendant(
            of: femaleTile, matching: find.byIcon(Icons.check_circle_rounded)),
        findsOneWidget);
    await tester.tap(find.text('Male'));
    await tester.pumpAndSettle();
    final maleTile =
        find.ancestor(of: find.text('Male'), matching: find.byType(InkWell));
    expect(
        find.descendant(
            of: maleTile, matching: find.byIcon(Icons.check_circle_rounded)),
        findsOneWidget);
  });
}
