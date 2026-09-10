import 'package:equatable/equatable.dart';

abstract class DoctorDetailsEvent extends Equatable {
  const DoctorDetailsEvent();
  @override
  List<Object?> get props => [];
}

class DoctorDetailsStarted extends DoctorDetailsEvent {
  final int doctorId;
  const DoctorDetailsStarted(this.doctorId);
  @override
  List<Object?> get props => [doctorId];
}
