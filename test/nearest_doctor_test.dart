import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/core/location/location_service.dart';
import 'package:vcare/core/utils/geo_distance.dart';
import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/data/repositories/doctor_repository.dart';
import 'package:vcare/data/repositories/favorites_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/logic/blocs/favorites/favorites_bloc.dart';
import 'package:vcare/logic/blocs/nearest_doctor/nearest_doctor_bloc.dart';
import 'package:vcare/logic/blocs/nearest_doctor/nearest_doctor_event.dart';
import 'package:vcare/logic/blocs/nearest_doctor/nearest_doctor_state.dart';
import 'package:vcare/presentation/display_format.dart';
import 'package:vcare/presentation/screans/doctor/nearest_doctor_screen.dart';
import 'package:vcare/presentation/widgets/doctor_card.dart';

/// Returns whatever it is told to, so every location outcome is reachable
/// without a device or the geolocator plugin.
class _StubLocationService implements LocationService {
  _StubLocationService(this.result);
  final LocationResult result;
  int settingsOpened = 0;

  @override
  Future<LocationResult> getCurrentLocation() async => result;

  @override
  Future<void> openPermissionSettings() async => settingsOpened++;
}

class _StubDoctorRepository implements DoctorRepository {
  _StubDoctorRepository({this.doctors = const [], this.throwError = false});
  final List<DoctorModel> doctors;
  final bool throwError;

  @override
  Future<List<DoctorModel>> getDoctors() async {
    if (throwError) throw const NetworkException();
    return doctors;
  }

  // The nearest-doctor flow only ever calls getDoctors(); the rest of the
  // interface is implemented so a stray call fails loudly instead of silently.
  @override
  Future<DoctorModel> getDoctorDetails(int id) => throw UnimplementedError();

  @override
  Future<List<DoctorModel>> searchDoctors(String name) =>
      throw UnimplementedError();
}

/// Minimal favorites stub so DoctorCard's heart button can build.
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

DoctorModel _doctor(int id, {double? lat, double? lng, String? name}) =>
    DoctorModel(
      id: id,
      name: name ?? 'Dr. Test $id',
      latitude: lat,
      longitude: lng,
      appointPrice: 100,
    );

void main() {
  // Cairo and Giza anchors, ~11 km apart in reality.
  const cairoLat = 30.0444, cairoLng = 31.2357;

  group('GeoDistance', () {
    test('returns 0 for identical points', () {
      final d = GeoDistance.metresBetween(
        startLatitude: cairoLat,
        startLongitude: cairoLng,
        endLatitude: cairoLat,
        endLongitude: cairoLng,
      );
      expect(d, isNotNull);
      expect(d!, closeTo(0, 0.001));
    });

    test('matches a known distance (Cairo → Alexandria ≈ 180 km)', () {
      final d = GeoDistance.metresBetween(
        startLatitude: cairoLat,
        startLongitude: cairoLng,
        endLatitude: 31.2001,
        endLongitude: 29.9187,
      )!;
      // Great-circle Cairo→Alexandria is ~180 km; allow 5 km of slack.
      expect(d / 1000, closeTo(180, 5));
    });

    test('is symmetric', () {
      final ab = GeoDistance.metresBetween(
          startLatitude: cairoLat,
          startLongitude: cairoLng,
          endLatitude: 31.2001,
          endLongitude: 29.9187)!;
      final ba = GeoDistance.metresBetween(
          startLatitude: 31.2001,
          startLongitude: 29.9187,
          endLatitude: cairoLat,
          endLongitude: cairoLng)!;
      expect(ab, closeTo(ba, 0.001));
    });

    test('returns null for missing or out-of-range coordinates', () {
      expect(
          GeoDistance.metresBetween(
              startLatitude: cairoLat,
              startLongitude: cairoLng,
              endLatitude: null,
              endLongitude: 31.0),
          isNull);
      // latitude beyond ±90
      expect(
          GeoDistance.metresBetween(
              startLatitude: cairoLat,
              startLongitude: cairoLng,
              endLatitude: 95.0,
              endLongitude: 31.0),
          isNull);
      // longitude beyond ±180
      expect(
          GeoDistance.metresBetween(
              startLatitude: cairoLat,
              startLongitude: cairoLng,
              endLatitude: 30.0,
              endLongitude: 200.0),
          isNull);
      expect(
          GeoDistance.metresBetween(
              startLatitude: double.nan,
              startLongitude: cairoLng,
              endLatitude: 30.0,
              endLongitude: 31.0),
          isNull);
    });

    test('isValidCoordinate accepts the edges and rejects beyond them', () {
      expect(GeoDistance.isValidCoordinate(90, 180), isTrue);
      expect(GeoDistance.isValidCoordinate(-90, -180), isTrue);
      expect(GeoDistance.isValidCoordinate(90.1, 0), isFalse);
      expect(GeoDistance.isValidCoordinate(null, 0), isFalse);
    });
  });

  group('NearestDoctorBloc.rank', () {
    test('sorts nearest first', () {
      final ranked = NearestDoctorBloc.rank(
        doctors: [
          _doctor(1, lat: 31.2001, lng: 29.9187), // Alexandria — farthest
          _doctor(2, lat: 30.0500, lng: 31.2400), // very close
          _doctor(3, lat: 30.0131, lng: 31.2089), // Giza — middle
        ],
        userLatitude: cairoLat,
        userLongitude: cairoLng,
      );

      expect(ranked.map((r) => r.doctor.id).toList(), [2, 3, 1]);
      // Distances must be non-decreasing.
      for (var i = 1; i < ranked.length; i++) {
        expect(ranked[i].distanceMetres,
            greaterThanOrEqualTo(ranked[i - 1].distanceMetres));
      }
    });

    test('drops doctors with missing or invalid coordinates', () {
      final ranked = NearestDoctorBloc.rank(
        doctors: [
          _doctor(1, lat: 30.05, lng: 31.24),
          _doctor(2), // no coordinates at all
          _doctor(3, lat: 999, lng: 31.0), // out of range
          _doctor(4, lat: 30.06, lng: null), // half-missing
        ],
        userLatitude: cairoLat,
        userLongitude: cairoLng,
      );

      expect(ranked.map((r) => r.doctor.id).toList(), [1]);
    });

    test('returns empty when no doctor has coordinates', () {
      final ranked = NearestDoctorBloc.rank(
        doctors: [_doctor(1), _doctor(2)],
        userLatitude: cairoLat,
        userLongitude: cairoLng,
      );
      expect(ranked, isEmpty);
    });

    test('returns empty when the user position is invalid', () {
      final ranked = NearestDoctorBloc.rank(
        doctors: [_doctor(1, lat: 30.05, lng: 31.24)],
        userLatitude: null,
        userLongitude: null,
      );
      expect(ranked, isEmpty);
    });
  });

  group('NearestDoctorBloc states', () {
    test('emits Loaded, sorted, on the happy path', () async {
      final bloc = NearestDoctorBloc(
        _StubDoctorRepository(doctors: [
          _doctor(1, lat: 31.2001, lng: 29.9187),
          _doctor(2, lat: 30.0500, lng: 31.2400),
        ]),
        _StubLocationService(
            const LocationResult.success(cairoLat, cairoLng)),
      );

      bloc.add(const NearestDoctorRequested());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<NearestDoctorLoading>(), isA<NearestDoctorLoaded>()]),
      );
      final state = bloc.state as NearestDoctorLoaded;
      expect(state.results.first.doctor.id, 2);
      await bloc.close();
    });

    test('emits NoDoctors when the API returns an empty list', () async {
      final bloc = NearestDoctorBloc(
        _StubDoctorRepository(doctors: const []),
        _StubLocationService(
            const LocationResult.success(cairoLat, cairoLng)),
      );
      bloc.add(const NearestDoctorRequested());
      await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<NearestDoctorLoading>(),
            isA<NearestDoctorNoDoctors>()
          ]));
      await bloc.close();
    });

    test('emits Empty when no doctor has coordinates', () async {
      final bloc = NearestDoctorBloc(
        _StubDoctorRepository(doctors: [_doctor(1), _doctor(2)]),
        _StubLocationService(
            const LocationResult.success(cairoLat, cairoLng)),
      );
      bloc.add(const NearestDoctorRequested());
      await expectLater(bloc.stream,
          emitsInOrder([isA<NearestDoctorLoading>(), isA<NearestDoctorEmpty>()]));
      await bloc.close();
    });

    test('permission denied never reaches the repository', () async {
      // A repository that would throw if touched proves the bloc short-circuits.
      final bloc = NearestDoctorBloc(
        _StubDoctorRepository(throwError: true),
        _StubLocationService(
            const LocationResult.failed(LocationFailure.permissionDenied)),
      );
      bloc.add(const NearestDoctorRequested());
      await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<NearestDoctorLoading>(),
            isA<NearestDoctorLocationUnavailable>()
          ]));
      final state = bloc.state as NearestDoctorLocationUnavailable;
      expect(state.failure, LocationFailure.permissionDenied);
      expect(state.needsSettings, isFalse); // retryable in place
      await bloc.close();
    });

    test('permanent denial asks for Settings instead of Retry', () async {
      final bloc = NearestDoctorBloc(
        _StubDoctorRepository(),
        _StubLocationService(const LocationResult.failed(
            LocationFailure.permissionDeniedForever)),
      );
      bloc.add(const NearestDoctorRequested());
      await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<NearestDoctorLoading>(),
            isA<NearestDoctorLocationUnavailable>()
          ]));
      expect(
          (bloc.state as NearestDoctorLocationUnavailable).needsSettings, isTrue);
      await bloc.close();
    });

    test('disabled GPS and unavailable fixes are reported distinctly',
        () async {
      for (final failure in [
        LocationFailure.serviceDisabled,
        LocationFailure.unavailable,
      ]) {
        final bloc = NearestDoctorBloc(
          _StubDoctorRepository(),
          _StubLocationService(LocationResult.failed(failure)),
        );
        bloc.add(const NearestDoctorRequested());
        await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<NearestDoctorLoading>(),
              isA<NearestDoctorLocationUnavailable>()
            ]));
        expect((bloc.state as NearestDoctorLocationUnavailable).failure,
            failure);
        await bloc.close();
      }
    });

    test('a failing doctor request surfaces as an error, not a crash',
        () async {
      final bloc = NearestDoctorBloc(
        _StubDoctorRepository(throwError: true),
        _StubLocationService(
            const LocationResult.success(cairoLat, cairoLng)),
      );
      bloc.add(const NearestDoctorRequested());
      await expectLater(bloc.stream,
          emitsInOrder([isA<NearestDoctorLoading>(), isA<NearestDoctorError>()]));
      await bloc.close();
    });
  });

  group('distance formatting', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('shows metres under a kilometre', () {
      expect(formatDistance(l10n, 350), contains('350'));
      expect(formatDistance(l10n, 350), contains('m'));
    });

    test('shows one decimal of kilometres between 1 and 10 km', () {
      expect(formatDistance(l10n, 1200), contains('1.2'));
      expect(formatDistance(l10n, 1200), contains('km'));
      // 1.25 km rounds up at one decimal.
      expect(formatDistance(l10n, 1250), contains('1.3'));
    });

    test('shows whole kilometres past 10 km', () {
      expect(formatDistance(l10n, 14300), contains('14'));
      expect(formatDistance(l10n, 14300), isNot(contains('.')));
    });
  });

  group('DoctorCard distance label', () {
    Widget wrap(Widget child) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<FavoritesBloc>(
            create: (_) => FavoritesBloc(_FakeFavoritesRepository()),
            child: Scaffold(body: child),
          ),
        );

    testWidgets('renders the label and opens details on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(DoctorCard(
        doctor: _doctor(7, lat: 30.05, lng: 31.24, name: 'Dr. Near'),
        distanceLabel: '1.2 km away',
        onTap: () => tapped = true,
      )));
      await tester.pump();

      expect(find.text('1.2 km away'), findsOneWidget);
      expect(find.text('Dr. Near'), findsOneWidget);

      await tester.tap(find.text('Dr. Near'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('omits the label when no distance is given', (tester) async {
      await tester.pumpWidget(wrap(DoctorCard(
        doctor: _doctor(8, name: 'Dr. NoDistance'),
      )));
      await tester.pump();

      expect(find.text('Dr. NoDistance'), findsOneWidget);
      expect(find.textContaining('away'), findsNothing);
    });
  });

  group('NearestDoctorScreen permission settings', () {
    testWidgets('Open Settings goes through the injected LocationService',
        (tester) async {
      final location = _StubLocationService(const LocationResult.failed(
          LocationFailure.permissionDeniedForever));

      await tester.pumpWidget(
        RepositoryProvider<LocationService>.value(
          value: location,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<NearestDoctorBloc>(
              create: (_) =>
                  NearestDoctorBloc(_StubDoctorRepository(), location),
              child: const NearestDoctorScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(location.settingsOpened, 0);
      await tester.tap(find.text('Open Settings'));
      await tester.pump();

      // The screen must not construct its own Geolocator service.
      expect(location.settingsOpened, 1);
    });
  });

  group('DoctorModel coordinate parsing', () {
    test('reads numeric and string coordinates', () {
      final fromNum = DoctorModel.fromJson(
          {'id': 1, 'name': 'A', 'latitude': 30.1, 'longitude': 31.2});
      expect(fromNum.latitude, 30.1);

      final fromString = DoctorModel.fromJson(
          {'id': 2, 'name': 'B', 'latitude': '30.5', 'longitude': '31.5'});
      expect(fromString.latitude, 30.5);
      expect(fromString.longitude, 31.5);
    });

    test('leaves coordinates null when absent or unparseable', () {
      final missing = DoctorModel.fromJson({'id': 3, 'name': 'C'});
      expect(missing.latitude, isNull);

      final junk = DoctorModel.fromJson(
          {'id': 4, 'name': 'D', 'latitude': 'abc', 'longitude': {}});
      expect(junk.latitude, isNull);
      expect(junk.longitude, isNull);
    });
  });
}
