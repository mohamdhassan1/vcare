import 'package:equatable/equatable.dart';
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
  final String message;
  const MyAppointmentsError(this.message);
  @override
  List<Object?> get props => [message];
}
