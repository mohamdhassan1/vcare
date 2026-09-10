import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
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
      final formatted = _formatStartTime(event.dateTime);
      final result = await _repository.storeAppointment(
          doctorId: event.doctorId, startTime: formatted, notes: event.notes);
      emit(BookAppointmentSuccess(
          appointmentTime: result.appointmentTime, status: result.status));
    } on AppException catch (e) {
      emit(BookAppointmentFailure(e.message));
    } catch (e) {
      emit(const BookAppointmentFailure(
          'Something went wrong. Please try again.'));
    }
  }

  String _formatStartTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
