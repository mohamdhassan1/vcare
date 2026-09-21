import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialization_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../data/repositories/specialization_repository.dart';
import '../../../data/repositories/user_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Outcome of one independent Home section. `value` is null when the
/// section failed; [error] carries the reason for logging.
class _Section<T> {
  const _Section.ok(this.value) : error = null;
  const _Section.failed(this.error) : value = null;
  final T? value;
  final Object? error;
  bool get failed => value == null;
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._userRepository, this._specializationRepository,
      this._doctorRepository)
      : super(const HomeLoading()) {
    on<HomeStarted>(_onHomeStarted);
  }

  final UserRepository _userRepository;
  final SpecializationRepository _specializationRepository;
  final DoctorRepository _doctorRepository;
  static const _sectionTimeout = Duration(seconds: 20);

  /// Runs one section's fetch with a timeout and turns any failure into
  /// a [_Section.failed] instead of throwing. Because the returned
  /// future never errors, the three sections can be started together
  /// and awaited one by one without an all-or-nothing Future.wait or
  /// an unhandled error from a section that fails before it's awaited.
  Future<_Section<T>> _load<T>(String name, Future<T> Function() fetch) async {
    try {
      final value = await fetch().timeout(_sectionTimeout,
          onTimeout: () => throw const AppException(
              'The request took too long. Please try again.',
              code: AppErrorCode.timeout));
      return _Section.ok(value);
    } catch (e) {
      debugPrint('[HOME] $name failed: $e');
      return _Section.failed(e);
    }
  }

  Future<void> _onHomeStarted(
      HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    debugPrint('[HOME] HomeStarted received');

    // The three sections are independent: start them concurrently so
    // Home appears after the slowest one rather than the sum of all.
    final profileFuture =
        _load<UserProfileModel>('Profile', _userRepository.getProfile);
    final specializationsFuture = _load<List<SpecializationModel>>(
        'Specializations', _specializationRepository.getSpecializations);
    final doctorsFuture =
        _load<List<DoctorModel>>('Doctors', _doctorRepository.getDoctors);

    final profile = await profileFuture;
    final specializations = await specializationsFuture;
    final doctors = await doctorsFuture;

    // Nothing loaded at all (typically offline or a dead session): a
    // full-screen error with Retry is the honest outcome. The 401 case
    // is already redirected by the global session handling.
    if (profile.failed && specializations.failed && doctors.failed) {
      emit(HomeError(AppErrorInfo.from(profile.error ?? Object())));
      return;
    }

    // Greeting: profile name, else the username saved at login (real
    // data from this session), else empty — never a made-up name.
    String userName = profile.value?.name ?? '';
    if (userName.isEmpty) {
      userName = await _userRepository.getStoredUsername() ?? '';
    }

    final failedSections = <String>[
      if (profile.failed) 'Profile could not be loaded.',
      if (specializations.failed) 'Specialties could not be loaded.',
      if (doctors.failed) 'Doctors could not be loaded.',
    ];

    debugPrint('[HOME] Emitting HomeLoaded '
        '(profileFailed:${profile.failed} '
        'specializationsFailed:${specializations.failed} '
        'doctorsFailed:${doctors.failed})');
    emit(HomeLoaded(
      userName: userName,
      specializations: specializations.value ?? const [],
      doctors: doctors.value ?? const [],
      partialErrorMessage:
          failedSections.isEmpty ? null : failedSections.join(' '),
      profileFailed: profile.failed,
      specializationsFailed: specializations.failed,
      doctorsFailed: doctors.failed,
    ));
  }
}
