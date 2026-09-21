import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/appointment_list_item_model.dart';

abstract class MyAppointmentsState extends Equatable {
  const MyAppointmentsState();
  @override
  List<Object?> get props => [];
}

class MyAppointmentsLoading extends MyAppointmentsState {
  const MyAppointmentsLoading();
}

class MyAppointmentsLoaded extends MyAppointmentsState {
  final List<AppointmentListItemModel> appointments;
  const MyAppointmentsLoaded(this.appointments);
  @override
  List<Object?> get props => [appointments];
}

class MyAppointmentsError extends MyAppointmentsState {
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const MyAppointmentsError(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
