import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/repositories/doctor_repository.dart';
import 'doctor_event.dart';
import 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  DoctorBloc(this._repository) : super(const DoctorLoading()) {
    on<DoctorListStarted>(_onStarted);
  }
  final DoctorRepository _repository;

  Future<void> _onStarted(
      DoctorListStarted event, Emitter<DoctorState> emit) async {
    emit(const DoctorLoading());
    try {
      final doctors = await _repository.getDoctors();
      emit(DoctorLoaded(doctors));
    } on AppException catch (e) {
      emit(DoctorError(e.message));
    } catch (e) {
      emit(const DoctorError('Something went wrong. Please try again.'));
    }
  }
}
