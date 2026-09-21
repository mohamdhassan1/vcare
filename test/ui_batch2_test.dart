// UI Batch 2 — main journey: labelled bottom navigation, Home search
// entry + specialty tiles, search result transitions, DoctorCard on
// AppCard with Hero + animated favorite, Doctor Details sticky CTA and
// unified rating, Specializations grid, responsive width.

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' show Tristate;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/routes/app_router.dart';
import 'package:vcare/core/routes/app_routes.dart';
import 'package:vcare/core/theme/app_dimensions.dart';
import 'package:vcare/core/theme/app_palette.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/data/models/appointment_list_item_model.dart';
import 'package:vcare/data/models/appointment_model.dart';
import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/data/models/specialization_model.dart';
import 'package:vcare/data/models/user_profile_model.dart';
import 'package:vcare/data/repositories/appointment_repository.dart';
import 'package:vcare/data/repositories/doctor_repository.dart';
import 'package:vcare/data/repositories/favorites_repository.dart';
import 'package:vcare/data/repositories/specialization_repository.dart';
import 'package:vcare/data/repositories/user_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/logic/blocs/favorites/favorites_bloc.dart';
import 'package:vcare/logic/blocs/home/home_bloc.dart';
import 'package:vcare/logic/blocs/my_appointments/my_appointments_bloc.dart';
import 'package:vcare/logic/blocs/search/search_bloc.dart';
import 'package:vcare/logic/blocs/specialization/specialization_bloc.dart';
import 'package:vcare/presentation/screans/appointments/book_appointment_screen.dart';
import 'package:vcare/presentation/screans/doctor/doctor_details_screen.dart';
import 'package:vcare/presentation/screans/home/home_screen.dart';
import 'package:vcare/presentation/screans/search/search_screen.dart';
import 'package:vcare/presentation/screans/specialization/specialization_list_screen.dart';
import 'package:vcare/presentation/widgets/app_bottom_nav.dart';
import 'package:vcare/presentation/widgets/app_card.dart';
import 'package:vcare/presentation/widgets/content_constraint.dart';
import 'package:vcare/presentation/widgets/doctor_card.dart';

// ---------------------------------------------------------------- fakes

const _specializations = [
  SpecializationModel(id: 1, name: 'Dermatology'),
  SpecializationModel(id: 2, name: 'Cardiology'),
  SpecializationModel(id: 3, name: 'Neurology'),
];

const _heart = DoctorModel(
  id: 2,
  name: 'Dr. Heart',
  specialization: 'Cardiology',
  hospital: 'City Clinic',
  rating: 4.5,
  reviewsCount: 12,
  appointPrice: 300,
  startTime: '09:00',
  endTime: '17:00',
  description: 'Cares about hearts.',
);

const _skin =
    DoctorModel(id: 1, name: 'Dr. Skin', specialization: 'Dermatology');

const _doctors = [_skin, _heart];

class _FakeDoctorRepository implements DoctorRepository {
  Completer<DoctorModel>? detailsGate;

  @override
  Future<List<DoctorModel>> getDoctors() async => _doctors;
  @override
  Future<List<DoctorModel>> searchDoctors(String name) async => _doctors
      .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
      .toList();
  @override
  Future<DoctorModel> getDoctorDetails(int id) =>
      detailsGate?.future ??
      Future.value(_doctors.firstWhere((d) => d.id == id));
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
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String gender,
    String? password,
  }) =>
      throw UnimplementedError();
}

class _FakeFavoritesRepository implements FavoritesRepository {
  Set<int> ids = {};
  @override
  Future<Set<int>> getFavoriteIds() async => ids;
  @override
  Future<Set<int>> toggleFavorite(int doctorId) async {
    ids = ids.contains(doctorId) ? (ids..remove(doctorId)) : {...ids, doctorId};
    return ids;
  }
}

class _FakeAppointmentRepository implements AppointmentRepository {
  @override
  Future<List<AppointmentListItemModel>> getAppointments() async => const [];
  @override
  Future<AppointmentModel> storeAppointment(
          {required int doctorId, required String startTime, String? notes}) =>
      throw UnimplementedError();
}

// -------------------------------------------------------------- helpers

final _en = AppLocalizationsEn();
final _ar = AppLocalizationsAr();

Widget _app(
  Widget home, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) =>
    MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: AppRouter.generateRoute,
      home: home,
    );

Widget _withBlocs(Widget child, {_FakeDoctorRepository? doctors}) {
  final doctorRepo = doctors ?? _FakeDoctorRepository();
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<DoctorRepository>.value(value: doctorRepo),
      RepositoryProvider<AppointmentRepository>(
          create: (_) => _FakeAppointmentRepository()),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<MyAppointmentsBloc>(
            create: (context) =>
                MyAppointmentsBloc(context.read<AppointmentRepository>())),
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            _FakeUserRepository(),
            _FakeSpecializationRepository(),
            doctorRepo,
          ),
        ),
        BlocProvider<SpecializationBloc>(
          create: (_) => SpecializationBloc(_FakeSpecializationRepository()),
        ),
        BlocProvider<SearchBloc>(
          create: (_) =>
              SearchBloc(doctorRepo, _FakeSpecializationRepository()),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => FavoritesBloc(_FakeFavoritesRepository()),
        ),
      ],
      child: child,
    ),
  );
}

void _usePhone(WidgetTester tester, {double width = 360}) {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

List<AppBottomNavItem> _items(AppLocalizations l10n) => [
      AppBottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.navHome,
      ),
      AppBottomNavItem(
        icon: Icons.auto_awesome_outlined,
        selectedIcon: Icons.auto_awesome,
        label: l10n.navAiAssistant,
      ),
      AppBottomNavItem(
        icon: Icons.calendar_today_outlined,
        selectedIcon: Icons.calendar_today_rounded,
        label: l10n.navAppointments,
      ),
      AppBottomNavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: l10n.navProfile,
      ),
    ];

void main() {
  group('Bottom navigation (C1/H2)', () {
    testWidgets(
        'labels are visible, selected tab is marked in semantics '
        'and taps report the index', (tester) async {
      final handle = tester.ensureSemantics();
      var tapped = -1;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: AppBottomNav(
              items: _items(_en),
              currentIndex: 0,
              onTap: (i) => tapped = i,
            ),
          ),
        ),
      );
      for (final label in [
        _en.navHome,
        _en.navAiAssistant,
        _en.navAppointments,
        _en.navProfile,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      final home = tester.getSemantics(find.bySemanticsLabel(_en.navHome));
      expect(home.flagsCollection.isSelected, Tristate.isTrue);
      final profile = tester.getSemantics(
        find.bySemanticsLabel(_en.navProfile),
      );
      expect(profile.flagsCollection.isSelected, isNot(Tristate.isTrue));
      // Selected icon differs from the unselected ones (not color alone).
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      await tester.tap(find.text(_en.navProfile));
      expect(tapped, 3);
      final target = tester.getSize(
        find.ancestor(
          of: find.text(_en.navProfile),
          matching: find.byType(InkResponse),
        ),
      );
      expect(target.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      expect(target.width, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      handle.dispose();
    });

    testWidgets('Arabic labels, first tab on the right in RTL', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: AppBottomNav(
              items: _items(_ar),
              currentIndex: 1,
              onTap: (_) {},
            ),
          ),
          locale: const Locale('ar'),
        ),
      );
      expect(find.text(_ar.navAiAssistant), findsOneWidget);
      final homeX = tester.getCenter(find.text(_ar.navHome)).dx;
      final profileX = tester.getCenter(find.text(_ar.navProfile)).dx;
      expect(homeX, greaterThan(profileX));
    });
  });

  group('Home (C2/M1/P6)', () {
    testWidgets('search entry opens the Search screen; tiles allow 2 lines', (
      tester,
    ) async {
      await tester.pumpWidget(_withBlocs(_app(const HomeScreen())));
      await tester.pumpAndSettle();

      expect(find.text(_en.searchDoctorsHint), findsOneWidget);
      final label = tester.widget<Text>(
        find.descendant(
          of: find.byType(ListView).last,
          matching: find.text('Dermatology'),
        ),
      );
      // A single long word is scaled to fit (never broken mid-word);
      // multi-word names get two lines.
      expect(label.maxLines, 1);
      expect(
          find.ancestor(
              of: find.text('Dermatology'), matching: find.byType(FittedBox)),
          findsOneWidget);

      await tester.tap(find.text(_en.searchDoctorsHint));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('banner text uses the theme onPrimary color (dark-safe)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _withBlocs(_app(const HomeScreen(), theme: AppTheme.dark)),
      );
      await tester.pumpAndSettle();
      final banner = tester.widget<Text>(find.text(_en.homeBannerTitle));
      expect(banner.style?.color, AppPalette.dark.onPrimary);
    });
  });

  group('DoctorCard + Details (H3/C3/M7/P1)', () {
    testWidgets(
        'card sits on AppCard, hero tag is per doctor, rating format '
        'is unified', (tester) async {
      await tester.pumpWidget(
        _withBlocs(
          _app(
            Scaffold(
              body: ListView(
                children: const [
                  DoctorCard(doctor: _skin),
                  DoctorCard(doctor: _heart),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppCard), findsNWidgets(2));
      final tags =
          tester.widgetList<Hero>(find.byType(Hero)).map((h) => h.tag).toList();
      expect(tags.toSet().length, 2, reason: 'no shared/colliding tag');
      expect(tags, contains(DoctorPresentation.heroTag(2)));
      expect(find.text('4.5 · ${_en.reviewsCount(12)}'), findsOneWidget);
      expect(find.text('4.5 (12)'), findsNothing);
    });

    testWidgets('favorite toggle animates and keeps its tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _withBlocs(
          _app(
            Scaffold(
              body: ListView(children: const [DoctorCard(doctor: _heart)]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip(_en.addToFavorites), findsOneWidget);
      await tester.tap(find.byTooltip(_en.addToFavorites));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      // Mid-transition both icons exist inside the AnimatedSwitcher.
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byTooltip(_en.removeFromFavorites), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    });

    testWidgets(
        'card → details: photo hero shows while loading, then the '
        'sticky Book bar with price appears and books the same route', (
      tester,
    ) async {
      final repo = _FakeDoctorRepository()..detailsGate = Completer();
      await tester.pumpWidget(
        _withBlocs(
          _app(
            Scaffold(
              body: Builder(
                builder: (context) => DoctorCard(
                  doctor: _heart,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.doctorDetails,
                    arguments: {'doctorId': 2, 'imageUrl': null},
                  ),
                ),
              ),
            ),
          ),
          doctors: repo,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr. Heart'));
      // Route transition frames only: the loading skeleton pulses, so
      // pumpAndSettle would never settle here.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DoctorDetailsScreen), findsOneWidget);
      // Still loading: the hero photo is already there, no CTA yet.
      expect(find.byType(Hero), findsOneWidget);
      expect(find.text(_en.bookAppointment), findsNothing);

      repo.detailsGate!.complete(_heart);
      await tester.pumpAndSettle();
      expect(find.text('Dr. Heart'), findsOneWidget);
      expect(find.text('4.5 · ${_en.reviewsCount(12)}'), findsOneWidget);
      expect(find.text(_en.pricePerVisit(r'$300')), findsOneWidget);
      expect(find.text(r'$300'), findsOneWidget, reason: 'bar price');
      expect(find.text(_en.perVisit), findsOneWidget);
      expect(find.text(_en.bookAppointment), findsOneWidget);
      final hours = tester.widget<Text>(find.text('09:00 - 17:00'));
      expect(hours.textDirection, TextDirection.ltr);

      // Regression: the bar must stay a bar at the bottom and the body
      // must keep its height (a full-height bar once hid the whole page).
      final screen = tester.getSize(find.byType(DoctorDetailsScreen));
      final barTop = tester.getRect(find.text(_en.bookAppointment)).top;
      expect(barTop, greaterThan(screen.height - 140),
          reason: 'CTA sits at the bottom, not at the top');
      expect(tester.getSize(find.byType(SingleChildScrollView)).height,
          greaterThan(screen.height / 2),
          reason: 'body keeps its height');
      expect(tester.getRect(find.text('Dr. Heart')).bottom, lessThan(barTop),
          reason: 'content is visible above the bar');

      // The CTA is in the Scaffold's bottom bar, not inside the scroll view.
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.text(_en.bookAppointment),
        ),
        findsNothing,
      );

      await tester.tap(find.text(_en.bookAppointment));
      await tester.pumpAndSettle();
      final booking = tester.widget<BookAppointmentScreen>(
        find.byType(BookAppointmentScreen),
      );
      expect(booking.doctorId, 2);
      expect(booking.doctorName, 'Dr. Heart');
    });

    testWidgets('router still accepts a bare int argument', (tester) async {
      await tester.pumpWidget(
        _withBlocs(
          _app(
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.doctorDetails,
                    arguments: 2,
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(DoctorDetailsScreen), findsOneWidget);
      expect(find.text('Dr. Heart'), findsOneWidget);
      expect(find.text(_en.pageCouldNotOpen), findsNothing);
    });

    test('photo size is bounded on every width', () {
      expect(DoctorDetailsScreen.photoSize(320), 140);
      expect(DoctorDetailsScreen.photoSize(400), 160);
      expect(DoctorDetailsScreen.photoSize(1400), 200);
    });
  });

  group('Search (M2)', () {
    testWidgets(
        'filter change cross-fades the result list and the count '
        'disappears when empty', (tester) async {
      await tester.pumpWidget(_withBlocs(_app(const SearchScreen())));
      await tester.pumpAndSettle();
      expect(find.text(_en.resultsFound(2)), findsOneWidget);
      final before = tester.widget<ListView>(find.byType(ListView).last).key;

      await tester.tap(find.text('Cardiology'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-fade: old and new lists coexist inside the AnimatedSwitcher.
      expect(find.byType(DoctorCard), findsNWidgets(3));
      await tester.pumpAndSettle();
      final after = tester.widget<ListView>(find.byType(ListView).last).key;
      expect(after, isNot(before));
      expect(find.text(_en.resultsFound(1)), findsOneWidget);

      await tester.tap(find.text('Neurology'));
      await tester.pumpAndSettle();
      expect(find.text(_en.noDoctorsFound), findsOneWidget);
      expect(find.textContaining('result'), findsNothing);
    });

    testWidgets('a pre-selected specialty is still honored', (tester) async {
      await tester.pumpWidget(
        _withBlocs(_app(const SearchScreen(initialSpecializationId: 2))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dr. Heart'), findsOneWidget);
      expect(find.text('Dr. Skin'), findsNothing);
    });
  });

  group('Specializations (M3)', () {
    testWidgets('tiles are AppCards that open the filtered Search', (
      tester,
    ) async {
      await tester.pumpWidget(
        _withBlocs(_app(const SpecializationListScreen())),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppCard), findsNWidgets(3));
      await tester.tap(find.text('Cardiology'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.text('Dr. Heart'), findsOneWidget);
      expect(find.text('Dr. Skin'), findsNothing);
    });
  });

  group('Responsive (H11)', () {
    testWidgets('content is capped at 640px on a wide window', (tester) async {
      _usePhone(tester, width: 1400);
      await tester.pumpWidget(_withBlocs(_app(const HomeScreen())));
      await tester.pumpAndSettle();
      expect(find.byType(ContentConstraint), findsOneWidget);
      expect(
        tester.getSize(find.byType(ListView).first).width,
        AppDimensions.contentMaxWidth,
      );
    });

    testWidgets('no overflow at 320px in English or Arabic', (tester) async {
      _usePhone(tester, width: 320);
      for (final locale in const [Locale('en'), Locale('ar')]) {
        for (final screen in <Widget>[
          const HomeScreen(),
          const SpecializationListScreen(),
          const SearchScreen(),
          const DoctorDetailsScreen(doctorId: 2),
        ]) {
          await tester.pumpWidget(_withBlocs(_app(screen, locale: locale)));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$screen / ${locale.languageCode}',
          );
        }
      }
    });
  });
}
