import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/repositories/appointment_repository.dart';
import 'my_appointments_event.dart';
import 'my_appointments_state.dart';

class MyAppointmentsBloc
    extends Bloc<MyAppointmentsEvent, MyAppointmentsState> {
  MyAppointmentsBloc(this._repository) : super(const MyAppointmentsLoading()) {
    on<MyAppointmentsStarted>(_onStarted);
  }
  final AppointmentRepository _repository;

  Future<void> _onStarted(
      MyAppointmentsStarted event, Emitter<MyAppointmentsState> emit) async {
    emit(const MyAppointmentsLoading());
    try {
      final appointments = await _repository.getAppointments();
      emit(MyAppointmentsLoaded(appointments));
    } on AppException catch (e) {
      emit(MyAppointmentsError(e.message));
    } catch (e) {
      emit(
          const MyAppointmentsError('Something went wrong. Please try again.'));
    }
  }
}
