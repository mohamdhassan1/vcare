import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialization_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Emitted whenever at least one Home section loaded. Sections are
/// independent: a failed one is flagged (and its list left empty) so
/// the UI can say "could not be loaded" instead of showing a false
/// "no doctors found" — while the successful sections still render.
class HomeLoaded extends HomeState {
  /// Display name for the greeting. Empty when neither the profile
  /// request nor the stored login username provided one.
  final String userName;
  final List<SpecializationModel> specializations;
  final List<DoctorModel> doctors;

  /// Human-readable summary of the failed sections (shown once in a
  /// SnackBar); null when everything loaded.
  final String? partialErrorMessage;

  /// Which sections failed. Empty lists with the flag false are simply
  /// "the server returned nothing" — a valid, non-error outcome.
  final bool profileFailed;
  final bool specializationsFailed;
  final bool doctorsFailed;

  const HomeLoaded({
    required this.userName,
    required this.specializations,
    required this.doctors,
    this.partialErrorMessage,
    this.profileFailed = false,
    this.specializationsFailed = false,
    this.doctorsFailed = false,
  });

  @override
  List<Object?> get props => [
        userName,
        specializations,
        doctors,
        partialErrorMessage,
        profileFailed,
        specializationsFailed,
        doctorsFailed,
      ];
}

/// Only when *every* section failed — there is nothing to show.
class HomeError extends HomeState {
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const HomeError(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
