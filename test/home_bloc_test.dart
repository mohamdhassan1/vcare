// B13 — Home sections are independent: one failing request must not
// hide the sections that succeeded, and failures are flagged explicitly.

import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/data/models/specialization_model.dart';
import 'package:vcare/data/models/user_profile_model.dart';
import 'package:vcare/data/repositories/doctor_repository.dart';
import 'package:vcare/data/repositories/specialization_repository.dart';
import 'package:vcare/data/repositories/user_repository.dart';
import 'package:vcare/logic/blocs/home/home_bloc.dart';
import 'package:vcare/logic/blocs/home/home_event.dart';
import 'package:vcare/logic/blocs/home/home_state.dart';

class _FakeUserRepository implements UserRepository {
  bool fail = false;
  String? storedUsername = 'stored-name';

  @override
  Future<UserProfileModel> getProfile() async {
    if (fail) throw const NetworkException();
    return const UserProfileModel(name: 'Mohamed');
  }

  @override
  Future<String?> getStoredUsername() async => storedUsername;

  @override
  Future<void> updateProfile(
          {required String name,
          required String email,
          required String phone,
          required String gender,
          String? password}) =>
      throw UnimplementedError();
}

class _FakeSpecializationRepository implements SpecializationRepository {
  bool fail = false;
  List<SpecializationModel> items = const [
    SpecializationModel(id: 1, name: 'Cardiology')
  ];

  @override
  Future<List<SpecializationModel>> getSpecializations() async {
    if (fail) throw const ServerException('Server error.', statusCode: 500);
    return items;
  }
}

class _FakeDoctorRepository implements DoctorRepository {
  bool fail = false;
  List<DoctorModel> items = const [DoctorModel(id: 1, name: 'Dr. One')];

  @override
  Future<List<DoctorModel>> getDoctors() async {
    if (fail) throw const NetworkException();
    return items;
  }

  @override
  Future<DoctorModel> getDoctorDetails(int id) => throw UnimplementedError();

  @override
  Future<List<DoctorModel>> searchDoctors(String name) =>
      throw UnimplementedError();
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late _FakeUserRepository users;
  late _FakeSpecializationRepository specializations;
  late _FakeDoctorRepository doctors;
  late HomeBloc bloc;

  setUp(() {
    users = _FakeUserRepository();
    specializations = _FakeSpecializationRepository();
    doctors = _FakeDoctorRepository();
    bloc = HomeBloc(users, specializations, doctors);
  });

  tearDown(() => bloc.close());

  Future<HomeLoaded> load() async {
    bloc.add(const HomeStarted());
    await _settle();
    expect(bloc.state, isA<HomeLoaded>());
    return bloc.state as HomeLoaded;
  }

  test('everything succeeds → no failure flags, no partial error', () async {
    final state = await load();
    expect(state.userName, 'Mohamed');
    expect(state.specializations, hasLength(1));
    expect(state.doctors, hasLength(1));
    expect(state.partialErrorMessage, isNull);
    expect(state.profileFailed, isFalse);
    expect(state.specializationsFailed, isFalse);
    expect(state.doctorsFailed, isFalse);
  });

  test('doctors failing keeps profile and specialties visible', () async {
    doctors.fail = true;
    final state = await load();
    expect(state.userName, 'Mohamed');
    expect(state.specializations, hasLength(1));
    expect(state.doctors, isEmpty);
    expect(state.doctorsFailed, isTrue);
    expect(state.specializationsFailed, isFalse);
    expect(state.partialErrorMessage, contains('Doctors'));
    expect(state.partialErrorMessage, isNot(contains('Specialties')));
  });

  test('profile failing keeps specialties and doctors; greets by stored name',
      () async {
    users.fail = true;
    final state = await load();
    expect(state.profileFailed, isTrue);
    expect(state.userName, 'stored-name');
    expect(state.specializations, hasLength(1));
    expect(state.doctors, hasLength(1));
    expect(state.partialErrorMessage, contains('Profile'));
  });

  test('profile failing with no stored name leaves the name empty', () async {
    users.fail = true;
    users.storedUsername = null;
    final state = await load();
    expect(state.userName, isEmpty, reason: 'never invent a name');
  });

  test('empty lists are a valid non-error outcome', () async {
    specializations.items = const [];
    doctors.items = const [];
    final state = await load();
    expect(state.specializations, isEmpty);
    expect(state.doctors, isEmpty);
    expect(state.specializationsFailed, isFalse);
    expect(state.doctorsFailed, isFalse);
    expect(state.partialErrorMessage, isNull);
  });

  test('two sections failing lists both in the partial error', () async {
    specializations.fail = true;
    doctors.fail = true;
    final state = await load();
    expect(state.userName, 'Mohamed');
    expect(state.specializationsFailed, isTrue);
    expect(state.doctorsFailed, isTrue);
    expect(state.partialErrorMessage, contains('Specialties'));
    expect(state.partialErrorMessage, contains('Doctors'));
  });

  test('every section failing is a full HomeError', () async {
    users.fail = true;
    specializations.fail = true;
    doctors.fail = true;
    bloc.add(const HomeStarted());
    await _settle();
    expect(bloc.state, isA<HomeError>());
    expect((bloc.state as HomeError).message, 'No internet connection.');
  });
}
