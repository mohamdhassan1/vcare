import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/repositories/doctor_repository.dart';
import 'doctor_details_event.dart';
import 'doctor_details_state.dart';

class DoctorDetailsBloc extends Bloc<DoctorDetailsEvent, DoctorDetailsState> {
  DoctorDetailsBloc(this._repository) : super(const DoctorDetailsLoading()) {
    on<DoctorDetailsStarted>(_onStarted);
  }
  final DoctorRepository _repository;

  Future<void> _onStarted(
      DoctorDetailsStarted event, Emitter<DoctorDetailsState> emit) async {
    emit(const DoctorDetailsLoading());
    try {
      final doctor = await _repository.getDoctorDetails(event.doctorId);
      emit(DoctorDetailsLoaded(doctor));
    } on AppException catch (e) {
      emit(DoctorDetailsError(AppErrorInfo.from(e)));
    } catch (e) {
      emit(const DoctorDetailsError(AppErrorInfo.unknown));
    }
  }
}
