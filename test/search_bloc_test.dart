// B4 — the newest search request must always win, even when an older
// request's response arrives later.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/data/models/specialization_model.dart';
import 'package:vcare/data/repositories/doctor_repository.dart';
import 'package:vcare/data/repositories/specialization_repository.dart';
import 'package:vcare/logic/blocs/search/search_bloc.dart';
import 'package:vcare/logic/blocs/search/search_event.dart';
import 'package:vcare/logic/blocs/search/search_state.dart';

/// Every searchDoctors() call stays pending until the test completes it,
/// so response order can be controlled explicitly.
class _ControlledDoctorRepository implements DoctorRepository {
  final Map<String, Completer<List<DoctorModel>>> pending = {};

  @override
  Future<List<DoctorModel>> searchDoctors(String name) {
    final completer = Completer<List<DoctorModel>>();
    pending[name] = completer;
    return completer.future;
  }

  @override
  Future<List<DoctorModel>> getDoctors() async => const [];

  @override
  Future<DoctorModel> getDoctorDetails(int id) => throw UnimplementedError();
}

class _EmptySpecializationRepository implements SpecializationRepository {
  @override
  Future<List<SpecializationModel>> getSpecializations() async => const [];
}

DoctorModel _doctor(int id, String name) => DoctorModel(id: id, name: name);

/// Lets queued bloc events and completed futures settle.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late _ControlledDoctorRepository doctors;
  late SearchBloc bloc;

  setUp(() {
    doctors = _ControlledDoctorRepository();
    bloc = SearchBloc(doctors, _EmptySpecializationRepository());
  });

  tearDown(() => bloc.close());

  test('a slow older result cannot overwrite the newer result', () async {
    bloc.add(const SearchQueryChanged('A'));
    await _settle();
    bloc.add(const SearchQueryChanged('ABC'));
    await _settle();
    expect(doctors.pending.keys, containsAll(['A', 'ABC']));

    // Newest request finishes first.
    doctors.pending['ABC']!.complete([_doctor(2, 'Dr. ABC')]);
    await _settle();
    var state = bloc.state;
    expect(state, isA<SearchLoaded>());
    expect((state as SearchLoaded).query, 'ABC');
    expect(state.doctors.map((d) => d.id), [2]);

    // Older request finishes late — must be ignored.
    doctors.pending['A']!.complete([_doctor(1, 'Dr. A')]);
    await _settle();
    state = bloc.state;
    expect(state, isA<SearchLoaded>());
    expect((state as SearchLoaded).query, 'ABC');
    expect(state.doctors.map((d) => d.id), [2]);
  });

  test('a late error from an older request cannot replace newer results',
      () async {
    bloc.add(const SearchQueryChanged('A'));
    await _settle();
    bloc.add(const SearchQueryChanged('ABC'));
    await _settle();

    doctors.pending['ABC']!.complete([_doctor(2, 'Dr. ABC')]);
    await _settle();
    expect(bloc.state, isA<SearchLoaded>());

    doctors.pending['A']!.completeError(const NetworkException());
    await _settle();
    expect(bloc.state, isA<SearchLoaded>(),
        reason: 'stale failure must not surface as SearchError');
    expect((bloc.state as SearchLoaded).query, 'ABC');
  });

  test('in-order responses still update normally', () async {
    bloc.add(const SearchQueryChanged('A'));
    await _settle();
    doctors.pending['A']!.complete([_doctor(1, 'Dr. A')]);
    await _settle();
    expect((bloc.state as SearchLoaded).doctors.map((d) => d.id), [1]);

    bloc.add(const SearchQueryChanged('AB'));
    await _settle();
    expect(bloc.state, isA<SearchLoading>());
    doctors.pending['AB']!.complete([_doctor(3, 'Dr. AB')]);
    await _settle();
    expect((bloc.state as SearchLoaded).doctors.map((d) => d.id), [3]);
  });

  // Phase 5 — opening Search from a specialty tile pre-selects that
  // specialty (client-side filter over the real doctor list).
  group('SearchOpened with a specialty', () {
    late SearchBloc specialtyBloc;

    setUp(() {
      specialtyBloc =
          SearchBloc(_StaticDoctorRepository(), _TwoSpecializations());
    });

    tearDown(() => specialtyBloc.close());

    test('pre-selects the specialty and filters the visible doctors', () async {
      specialtyBloc.add(const SearchOpened(specializationId: 2));
      await _settle();
      final state = specialtyBloc.state as SearchLoaded;
      expect(state.selectedSpecializationId, 2);
      expect(state.doctors, hasLength(3), reason: 'full list is kept');
      expect(state.visibleDoctors.map((d) => d.name), ['Dr. Heart']);
      expect(state.query, isEmpty);
    });

    test('an unknown specialty id is ignored (nothing hidden)', () async {
      specialtyBloc.add(const SearchOpened(specializationId: 99));
      await _settle();
      final state = specialtyBloc.state as SearchLoaded;
      expect(state.selectedSpecializationId, isNull);
      expect(state.visibleDoctors, hasLength(3));
    });

    test('a plain SearchOpened resets the filter', () async {
      specialtyBloc.add(const SearchOpened(specializationId: 2));
      await _settle();
      specialtyBloc.add(const SearchOpened());
      await _settle();
      expect((specialtyBloc.state as SearchLoaded).selectedSpecializationId,
          isNull);
    });

    test('typing keeps the pre-selected specialty', () async {
      specialtyBloc.add(const SearchOpened(specializationId: 1));
      await _settle();
      specialtyBloc.add(const SearchQueryChanged('dr'));
      await _settle();
      final state = specialtyBloc.state as SearchLoaded;
      expect(state.selectedSpecializationId, 1);
      expect(
          state.visibleDoctors.map((d) => d.name), ['Dr. Tooth', 'Dr. Molar']);
    });
  });
}

class _StaticDoctorRepository implements DoctorRepository {
  static const _all = [
    DoctorModel(id: 1, name: 'Dr. Tooth', specialization: 'Dentistry'),
    DoctorModel(id: 2, name: 'Dr. Heart', specialization: 'Cardiology'),
    DoctorModel(id: 3, name: 'Dr. Molar', specialization: 'dentistry'),
  ];

  @override
  Future<List<DoctorModel>> getDoctors() async => _all;

  @override
  Future<List<DoctorModel>> searchDoctors(String name) async => _all;

  @override
  Future<DoctorModel> getDoctorDetails(int id) => throw UnimplementedError();
}

class _TwoSpecializations implements SpecializationRepository {
  @override
  Future<List<SpecializationModel>> getSpecializations() async => const [
        SpecializationModel(id: 1, name: 'Dentistry'),
        SpecializationModel(id: 2, name: 'Cardiology'),
      ];
}
