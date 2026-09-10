import 'package:equatable/equatable.dart';

abstract class BookAppointmentEvent extends Equatable {
  const BookAppointmentEvent();
  @override
  List<Object?> get props => [];
}

class BookAppointmentSubmitted extends BookAppointmentEvent {
  final int doctorId;
  final DateTime dateTime;
  final String? notes;

  const BookAppointmentSubmitted(
      {required this.doctorId, required this.dateTime, this.notes});

  @override
  List<Object?> get props => [doctorId, dateTime, notes];
}
