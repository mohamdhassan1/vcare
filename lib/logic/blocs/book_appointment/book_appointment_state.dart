import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';

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
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const BookAppointmentFailure(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
