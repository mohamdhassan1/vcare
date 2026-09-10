import 'package:equatable/equatable.dart';

abstract class BookAppointmentState extends Equatable {
  const BookAppointmentState();
  @override
  List<Object?> get props => [];
}

class BookAppointmentInitial extends BookAppointmentState {
  const BookAppointmentInitial();
}

class BookAppointmentSubmitting extends BookAppointmentState {
  const BookAppointmentSubmitting();
}

class BookAppointmentSuccess extends BookAppointmentState {
  final String? appointmentTime;
  final String? status;
  const BookAppointmentSuccess({this.appointmentTime, this.status});
  @override
  List<Object?> get props => [appointmentTime, status];
}

class BookAppointmentFailure extends BookAppointmentState {
  final String message;
  const BookAppointmentFailure(this.message);
  @override
  List<Object?> get props => [message];
}
