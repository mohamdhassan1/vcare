import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/location/location_service.dart';
import '../../../data/models/doctor_model.dart';

/// One doctor paired with how far they are from the user, in metres.
class DoctorWithDistance extends Equatable {
  const DoctorWithDistance(this.doctor, this.distanceMetres);

  final DoctorModel doctor;

  /// Always a real measured distance — a doctor is only wrapped in this
  /// class when both the user's fix and the clinic's coordinates are valid.
  final double distanceMetres;

  @override
  List<Object?> get props => [doctor.id, distanceMetres];
}

abstract class NearestDoctorState extends Equatable {
  const NearestDoctorState();
  @override
  List<Object?> get props => [];
}

class NearestDoctorInitial extends NearestDoctorState {
  const NearestDoctorInitial();
}

/// Covers both "locating you" and "loading doctors" — one spinner, because
/// to the user it is a single wait.
class NearestDoctorLoading extends NearestDoctorState {
  const NearestDoctorLoading();
}

/// Sorted nearest-first. Never empty — [NearestDoctorEmpty] covers that.
class NearestDoctorLoaded extends NearestDoctorState {
  const NearestDoctorLoaded(this.results);
  final List<DoctorWithDistance> results;
  @override
  List<Object?> get props => [results];
}

/// Doctors loaded fine, but none of them had usable coordinates.
class NearestDoctorEmpty extends NearestDoctorState {
  const NearestDoctorEmpty();
}

/// The API returned no doctors at all — a different problem from "none of
/// them has a location", so the UI says so rather than blaming coordinates.
class NearestDoctorNoDoctors extends NearestDoctorState {
  const NearestDoctorNoDoctors();
}

/// The user could not be located. [failure] decides whether the UI offers
/// "Try again" or "Open settings".
class NearestDoctorLocationUnavailable extends NearestDoctorState {
  const NearestDoctorLocationUnavailable(this.failure);
  final LocationFailure failure;

  /// Only a permanent denial needs the settings screen; everything else is
  /// retryable in place.
  bool get needsSettings => failure == LocationFailure.permissionDeniedForever;

  @override
  List<Object?> get props => [failure];
}

/// Fetching the doctor list itself failed (network, server, parsing).
class NearestDoctorError extends NearestDoctorState {
  const NearestDoctorError(this.error);
  final AppErrorInfo error;
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
