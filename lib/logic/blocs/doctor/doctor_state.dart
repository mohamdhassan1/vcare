import 'package:equatable/equatable.dart';
import '../../../data/models/doctor_model.dart';

abstract class DoctorState extends Equatable {
  const DoctorState();
  @override
  List<Object?> get props => [];
}

class DoctorLoading extends DoctorState {
  const DoctorLoading();
}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  const DoctorLoaded(this.doctors);
  @override
  List<Object?> get props => [doctors];
}

class DoctorError extends DoctorState {
  final String message;
  const DoctorError(this.message);
  @override
  List<Object?> get props => [message];
}
