import 'package:equatable/equatable.dart';
import '../../../data/models/doctor_model.dart';

abstract class DoctorDetailsState extends Equatable {
  const DoctorDetailsState();
  @override
  List<Object?> get props => [];
}

class DoctorDetailsLoading extends DoctorDetailsState {
  const DoctorDetailsLoading();
}

class DoctorDetailsLoaded extends DoctorDetailsState {
  final DoctorModel doctor;
  const DoctorDetailsLoaded(this.doctor);
  @override
  List<Object?> get props => [doctor];
}

class DoctorDetailsError extends DoctorDetailsState {
  final String message;
  const DoctorDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}
