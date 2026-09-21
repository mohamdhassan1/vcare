import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
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
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const DoctorError(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
