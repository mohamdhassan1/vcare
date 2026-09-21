import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/appointment_slots.dart';
import '../../../data/repositories/appointment_repository.dart';
import 'book_appointment_event.dart';
import 'book_appointment_state.dart';

class BookAppointmentBloc
    extends Bloc<BookAppointmentEvent, BookAppointmentState> {
  BookAppointmentBloc(this._repository)
      : super(const BookAppointmentInitial()) {
    on<BookAppointmentSubmitted>(_onSubmitted);
  }

  final AppointmentRepository _repository;

  Future<void> _onSubmitted(BookAppointmentSubmitted event,
      Emitter<BookAppointmentState> emit) async {
    emit(const BookAppointmentSubmitting());
    try {
      final formatted = AppointmentSlots.formatStartTime(event.dateTime);
      // Success is only ever emitted from a confirmed server response;
      // nothing is stored locally, so a failed booking can never show
      // up as an appointment.
      final result = await _repository.storeAppointment(
          doctorId: event.doctorId, startTime: formatted, notes: event.notes);
      emit(BookAppointmentSuccess(
          appointmentTime: result.appointmentTime, status: result.status));
    } on AppException catch (e) {
      emit(BookAppointmentFailure(AppErrorInfo.from(e)));
    } catch (e) {
      emit(const BookAppointmentFailure(AppErrorInfo.unknown));
    }
  }
}
