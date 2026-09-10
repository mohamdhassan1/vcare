import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/user_repository.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  UpdateProfileBloc(this._repository) : super(const UpdateProfileInitial()) {
    on<UpdateProfileSubmitted>(_onSubmitted);
  }
  final UserRepository _repository;

  Future<void> _onSubmitted(UpdateProfileSubmitted event, Emitter<UpdateProfileState> emit) async {
    emit(const UpdateProfileSubmitting());
    try {
      await _repository.updateProfile(name: event.name, email: event.email, phone: event.phone, gender: event.gender);
      emit(const UpdateProfileSuccess());
    } on AppException catch (e) {
      emit(UpdateProfileFailure(e.message));
    } catch (e) {
      emit(const UpdateProfileFailure('Something went wrong. Please try again.'));
    }
  }
}