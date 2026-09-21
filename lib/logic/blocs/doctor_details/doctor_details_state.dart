import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
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
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const DoctorDetailsError(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
