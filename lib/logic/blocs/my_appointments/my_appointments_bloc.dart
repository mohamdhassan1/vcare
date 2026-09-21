import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/repositories/appointment_repository.dart';
import 'my_appointments_event.dart';
import 'my_appointments_state.dart';

/// App-level (provided in main.dart) so the Appointments tab, the
/// pushed "My Appointment" route and the booking screen all share one
/// list: a successful booking dispatches [MyAppointmentsStarted] and
/// every consumer sees the refreshed backend list.
class MyAppointmentsBloc
    extends Bloc<MyAppointmentsEvent, MyAppointmentsState> {
  MyAppointmentsBloc(this._repository) : super(const MyAppointmentsLoading()) {
    on<MyAppointmentsStarted>(_onStarted);
  }
  final AppointmentRepository _repository;

  /// True while a GET /appointment/index is running. A refresh that
  /// arrives meanwhile (e.g. the tab opening right after a booking
  /// already triggered one) is dropped: the in-flight request will
  /// deliver the same fresh list, so a second call would be a
  /// duplicate.
  bool _isLoading = false;

  Future<void> _onStarted(
      MyAppointmentsStarted event, Emitter<MyAppointmentsState> emit) async {
    if (_isLoading) {
      debugPrint('[APPOINTMENTS] Refresh already in flight — skipped.');
      return;
    }
    _isLoading = true;
    emit(const MyAppointmentsLoading());
    try {
      // The backend list is the only source of truth: it replaces the
      // previous state wholesale, so refreshing can never duplicate
      // an appointment or keep one the server no longer returns.
      final appointments = await _repository.getAppointments();
      emit(MyAppointmentsLoaded(appointments));
    } on AppException catch (e) {
      emit(MyAppointmentsError(AppErrorInfo.from(e)));
    } catch (e) {
      debugPrint('[APPOINTMENTS] Unexpected error: $e');
      emit(const MyAppointmentsError(AppErrorInfo.unknown));
    } finally {
      _isLoading = false;
    }
  }
}
