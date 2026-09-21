// Phase 5 — doctors by specialty (Home tile / Specialties grid → Search
// pre-filtered), localized appointment status, and the logout
// confirmation dialog. All rendered with the real screens, routes and
// localizations; repositories are in-memory fakes.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vcare/core/locale/locale_controller.dart';
import 'package:vcare/core/theme/theme_controller.dart';
import 'package:vcare/core/routes/app_router.dart';
import 'package:vcare/core/routes/app_routes.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/data/models/appointment_list_item_model.dart';
import 'package:vcare/data/models/appointment_model.dart';
import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/data/models/specialization_model.dart';
import 'package:vcare/data/models/user_profile_model.dart';
import 'package:vcare/data/repositories/appointment_repository.dart';
import 'package:vcare/data/repositories/auth_repository.dart';
import 'package:vcare/data/repositories/doctor_repository.dart';
import 'package:vcare/data/repositories/favorites_repository.dart';
import 'package:vcare/data/repositories/specialization_repository.dart';
import 'package:vcare/data/repositories/user_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/logic/blocs/auth/auth_bloc.dart';
import 'package:vcare/logic/blocs/doctor/doctor_bloc.dart';
import 'package:vcare/logic/blocs/favorites/favorites_bloc.dart';
import 'package:vcare/logic/blocs/home/home_bloc.dart';
import 'package:vcare/logic/blocs/my_appointments/my_appointments_bloc.dart';
import 'package:vcare/logic/blocs/search/search_bloc.dart';
import 'package:vcare/logic/blocs/search/search_state.dart';
import 'package:vcare/logic/blocs/specialization/specialization_bloc.dart';
import 'package:vcare/presentation/screans/appointments/appointments_screen.dart';
import 'package:vcare/presentation/screans/doctor/doctor_list_screen.dart';
import 'package:vcare/presentation/screans/home/home_screen.dart';
import 'package:vcare/presentation/screans/profile/settings_screen.dart';
import 'package:vcare/presentation/screans/search/search_screen.dart';
import 'package:vcare/presentation/screans/specialization/specialization_list_screen.dart';

// ---------------------------------------------------------------- fakes

const _specializations = [
  SpecializationModel(id: 1, name: 'Dentistry'),
  SpecializationModel(id: 2, name: 'Cardiology'),
];

const _doctors = [
  DoctorModel(id: 1, name: 'Dr. Tooth', specialization: 'Dentistry'),
  DoctorModel(id: 2, name: 'Dr. Heart', specialization: 'Cardiology'),
  DoctorModel(id: 3, name: 'Dr. Molar', specialization: 'Dentistry'),
];

class _FakeDoctorRepository implements DoctorRepository {
  @override
  Future<List<DoctorModel>> getDoctors() async => _doctors;
  @override
  Future<List<DoctorModel>> searchDoctors(String name) async => _doctors
      .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
      .toList();
  @override
  Future<DoctorModel> getDoctorDetails(int id) => throw UnimplementedError();
}

class _FakeSpecializationRepository implements SpecializationRepository {
  @override
  Future<List<SpecializationModel>> getSpecializations() async =>
      _specializations;
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserProfileModel> getProfile() async =>
      const UserProfileModel(name: 'Sara', email: 's@example.com');
  @override
  Future<String?> getStoredUsername() async => 'Sara';
  @override
  Future<void> updateProfile(
          {required String name,
          required String email,
          required String phone,
          required String gender,
          String? password}) =>
      throw UnimplementedError();
}

class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<int>> getFavoriteIds() async => {};
  @override
  Future<Set<int>> toggleFavorite(int doctorId) async => {doctorId};
}

class _FakeAppointmentRepository implements AppointmentRepository {
  _FakeAppointmentRepository(this.items);
  final List<AppointmentListItemModel> items;
  @override
  Future<List<AppointmentListItemModel>> getAppointments() async => items;
  @override
  Future<AppointmentModel> storeAppointment(
          {required int doctorId, required String startTime, String? notes}) =>
      throw UnimplementedError();
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

/// App shell with the real router so `Navigator.pushNamed` works.
Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: AppRouter.generateRoute,
      home: home,
    );

/// The blocs the discovery screens need, wired to the fakes above. Wraps
/// the MaterialApp (like main.dart) so pushed routes can read them too.
Widget _withDiscoveryBlocs(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
            create: (_) => HomeBloc(_FakeUserRepository(),
                _FakeSpecializationRepository(), _FakeDoctorRepository())),
        BlocProvider<SpecializationBloc>(
            create: (_) => SpecializationBloc(_FakeSpecializationRepository())),
        BlocProvider<SearchBloc>(
            create: (_) => SearchBloc(
                _FakeDoctorRepository(), _FakeSpecializationRepository())),
        BlocProvider<FavoritesBloc>(
            create: (_) => FavoritesBloc(_FakeFavoritesRepository())),
        BlocProvider<DoctorBloc>(
            create: (_) => DoctorBloc(_FakeDoctorRepository())),
      ],
      child: child,
    );

ChoiceChip _chip(WidgetTester tester, String label) =>
    tester.widget<ChoiceChip>(
        find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)));

void main() {
  group('Doctors by specialty', () {
    testWidgets('Specialties grid → Search pre-filtered by that specialty',
        (tester) async {
      await tester.pumpWidget(
          _withDiscoveryBlocs(_app(const SpecializationListScreen())));
      await tester.pumpAndSettle();

      expect(find.text('Cardiology'), findsOneWidget);
      await tester.tap(find.text('Cardiology'));
      await tester.pumpAndSettle();

      // Landed on Search with the chip selected, no "coming soon".
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(_chip(tester, 'Cardiology').selected, isTrue);
      expect(_chip(tester, _en.all).selected, isFalse);
      // Only cardiologists are listed, the count says so.
      expect(find.text('Dr. Heart'), findsOneWidget);
      expect(find.text('Dr. Tooth'), findsNothing);
      expect(find.text(_en.resultsFound(1)), findsOneWidget);

      // "All" clears the filter again — everyone is back.
      await tester.tap(find.text(_en.all));
      await tester.pumpAndSettle();
      expect(find.text('Dr. Tooth'), findsOneWidget);
      expect(find.text(_en.resultsFound(3)), findsOneWidget);
    });

    testWidgets('Home specialty tile → Search pre-filtered', (tester) async {
      await tester.pumpWidget(_withDiscoveryBlocs(_app(const HomeScreen())));
      await tester.pumpAndSettle();

      // "Dentistry" also appears in the doctor cards below; tap the
      // specialty tile (the one inside the horizontal strip).
      await tester.tap(find.descendant(
          of: find.byType(ListView).last, matching: find.text('Dentistry')));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(_chip(tester, 'Dentistry').selected, isTrue);
      expect(find.text('Dr. Tooth'), findsOneWidget);
      expect(find.text('Dr. Molar'), findsOneWidget);
      expect(find.text('Dr. Heart'), findsNothing);
    });

    testWidgets('Search opened without an argument shows everyone',
        (tester) async {
      await tester.pumpWidget(_withDiscoveryBlocs(_app(Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
            child: const Text('go'),
          ),
        ),
      ))));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(_chip(tester, _en.all).selected, isTrue);
      expect(find.text(_en.resultsFound(3)), findsOneWidget);
      final state = tester
          .element(find.byType(SearchScreen))
          .read<SearchBloc>()
          .state as SearchLoaded;
      expect(state.selectedSpecializationId, isNull);
    });

    testWidgets('an unexpected route argument is ignored safely',
        (tester) async {
      await tester.pumpWidget(_withDiscoveryBlocs(_app(Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.search,
                arguments: 'not-an-id'),
            child: const Text('go'),
          ),
        ),
      ))));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(_chip(tester, _en.all).selected, isTrue);
    });

    testWidgets('Arabic: Specialties grid still opens the filtered Search',
        (tester) async {
      await tester.pumpWidget(_withDiscoveryBlocs(
          _app(const SpecializationListScreen(), locale: const Locale('ar'))));
      await tester.pumpAndSettle();
      expect(find.text(_ar.doctorSpeciality), findsOneWidget);

      await tester.tap(find.text('Cardiology'));
      await tester.pumpAndSettle();
      expect(find.text(_ar.search), findsOneWidget);
      expect(_chip(tester, 'Cardiology').selected, isTrue);
      expect(find.text(_ar.resultsFound(1)), findsOneWidget);
    });
  });

  group('Appointment status', () {
    Widget screen(List<AppointmentListItemModel> items, Locale locale) => _app(
          BlocProvider<MyAppointmentsBloc>(
              create: (_) =>
                  MyAppointmentsBloc(_FakeAppointmentRepository(items)),
              child: const AppointmentsScreen()),
          locale: locale,
        );

    testWidgets('"pending" is localized; unknown statuses are shown as-is',
        (tester) async {
      const items = [
        AppointmentListItemModel(
            id: 1, doctorName: 'Dr. Heart', status: 'Pending'),
        AppointmentListItemModel(
            id: 2, doctorName: 'Dr. Tooth', status: 'rescheduled'),
      ];
      await tester.pumpWidget(screen(items, const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text(_en.statusPending), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('rescheduled'), findsOneWidget);

      await tester.pumpWidget(screen(items, const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text(_ar.statusPending), findsOneWidget);
      expect(find.text('Pending'), findsNothing);
      expect(find.text('rescheduled'), findsOneWidget);
    });
  });

  group('Logout confirmation', () {
    late _FakeAuthRepository auth;
    late AuthBloc authBloc;

    setUp(() {
      auth = _FakeAuthRepository();
      authBloc = AuthBloc(auth);
    });

    tearDown(() => authBloc.close());

    // Settings shows the current language/theme, so it needs the two
    // controllers the app provides in main.dart.
    Widget settings(Locale locale) => MultiProvider(
          providers: [
            ListenableProvider<LocaleController>.value(
                value: LocaleController(locale)),
            ListenableProvider<ThemeController>.value(
                value: ThemeController(ThemeMode.light)),
          ],
          child: _app(
              BlocProvider<AuthBloc>.value(
                  value: authBloc, child: const SettingsScreen()),
              locale: locale),
        );

    testWidgets('Cancel keeps the session; Logout ends it', (tester) async {
      await tester.pumpWidget(settings(const Locale('en')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.logout));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(_en.logoutConfirmTitle), findsOneWidget);
      expect(find.text(_en.logoutConfirmMessage), findsOneWidget);

      await tester.tap(find.text(_en.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(auth.logoutCalls, 0, reason: 'nothing happens on Cancel');

      await tester.tap(find.text(_en.logout));
      await tester.pumpAndSettle();
      // The dialog's own Logout button (the list row is behind the barrier).
      await tester.tap(find.descendant(
          of: find.byType(AlertDialog), matching: find.text(_en.logout)));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(auth.logoutCalls, 1, reason: 'existing LogoutRequested flow ran');
    });

    testWidgets('Arabic dialog text', (tester) async {
      await tester.pumpWidget(settings(const Locale('ar')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_ar.logout));
      await tester.pumpAndSettle();
      expect(find.text(_ar.logoutConfirmTitle), findsOneWidget);
      expect(find.text(_ar.logoutConfirmMessage), findsOneWidget);
      expect(find.text(_ar.cancel), findsOneWidget);
    });
  });
  // UI Batch 1 — empty states offer a next step; search echoes the query.
  group('UI Batch 1 integration', () {
    testWidgets('empty appointments → "Browse Doctors" opens the doctor list',
        (tester) async {
      await tester.pumpWidget(_withDiscoveryBlocs(_app(
        BlocProvider<MyAppointmentsBloc>(
            create: (_) =>
                MyAppointmentsBloc(_FakeAppointmentRepository(const [])),
            child: const AppointmentsScreen()),
      )));
      await tester.pumpAndSettle();
      expect(find.text(_en.noAppointmentsYet), findsOneWidget);
      await tester.tap(find.text(_en.browseDoctors));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorListScreen), findsOneWidget);
      expect(find.text('Dr. Heart'), findsOneWidget);
    });

    testWidgets('search with no matches names the query, no "0 results" line',
        (tester) async {
      await tester.pumpWidget(_withDiscoveryBlocs(_app(const SearchScreen())));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 450)); // debounce
      await tester.pumpAndSettle();
      expect(find.text(_en.noDoctorsFoundFor('zzz')), findsOneWidget);
      expect(find.text(_en.resultsFound(0)), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
