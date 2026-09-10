import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/repositories/specialization_repository.dart';
import 'specialization_event.dart';
import 'specialization_state.dart';

class SpecializationBloc
    extends Bloc<SpecializationEvent, SpecializationState> {
  SpecializationBloc(this._repository) : super(const SpecializationLoading()) {
    on<SpecializationListStarted>(_onStarted);
  }

  final SpecializationRepository _repository;

  Future<void> _onStarted(SpecializationListStarted event,
      Emitter<SpecializationState> emit) async {
    emit(const SpecializationLoading());
    try {
      final specializations = await _repository.getSpecializations();
      emit(SpecializationLoaded(specializations));
    } on AppException catch (e) {
      emit(SpecializationError(e.message));
    } catch (e) {
      emit(
          const SpecializationError('Something went wrong. Please try again.'));
    }
  }
}
