import 'package:equatable/equatable.dart';

abstract class MyAppointmentsEvent extends Equatable {
  const MyAppointmentsEvent();
  @override
  List<Object?> get props => [];
}

class MyAppointmentsStarted extends MyAppointmentsEvent {
  const MyAppointmentsStarted();
}
