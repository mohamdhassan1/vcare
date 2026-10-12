import 'package:equatable/equatable.dart';

abstract class NearestDoctorEvent extends Equatable {
  const NearestDoctorEvent();
  @override
  List<Object?> get props => [];
}

/// Fired when the screen opens and again on every "Try again" tap. The
/// location permission prompt happens here, not before.
class NearestDoctorRequested extends NearestDoctorEvent {
  const NearestDoctorRequested();
}
