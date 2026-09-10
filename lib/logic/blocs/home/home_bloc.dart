import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialization_model.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../data/repositories/specialization_repository.dart';
import '../../../data/repositories/user_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._userRepository, this._specializationRepository,
      this._doctorRepository)
      : super(const HomeLoading()) {
    on<HomeStarted>(_onHomeStarted);
  }

  final UserRepository _userRepository;
  final SpecializationRepository _specializationRepository;
  final DoctorRepository _doctorRepository;
  static const _sectionTimeout = Duration(seconds: 20);

  Future<void> _onHomeStarted(
      HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    debugPrint('[HOME] HomeStarted received');

    final String userName;
    try {
      final profile = await _userRepository.getProfile().timeout(
          _sectionTimeout,
          onTimeout: () => throw const ServerException(
              'The request took too long. Please try again.'));
      userName = profile.name;
      debugPrint('[HOME] Profile loaded: $userName');
    } on AppException catch (e) {
      debugPrint('[HOME] Profile failed: ${e.message}');
      emit(HomeError(e.message));
      return;
    } catch (e) {
      debugPrint('[HOME] Profile unexpected error: $e');
      emit(const HomeError('Something went wrong. Please try again.'));
      return;
    }

    List<SpecializationModel> specializations = [];
    String? partialError;
    try {
      specializations = await _specializationRepository
          .getSpecializations()
          .timeout(_sectionTimeout,
              onTimeout: () => throw const ServerException(
                  'Specialties took too long to load.'));
      debugPrint('[HOME] Specializations loaded: ${specializations.length}');
    } catch (e) {
      debugPrint('[HOME] Specializations failed: $e');
      partialError = 'Specialties could not be loaded.';
    }

    List<DoctorModel> doctors = [];
    try {
      doctors = await _doctorRepository.getDoctors().timeout(_sectionTimeout,
          onTimeout: () =>
              throw const ServerException('Doctors took too long to load.'));
      debugPrint('[HOME] Doctors loaded: ${doctors.length}');
    } catch (e) {
      debugPrint('[HOME] Doctors failed: $e');
      partialError = partialError == null
          ? 'Doctors could not be loaded.'
          : '$partialError Doctors could not be loaded.';
    }

    debugPrint('[HOME] Emitting HomeLoaded');
    emit(HomeLoaded(
        userName: userName,
        specializations: specializations,
        doctors: doctors,
        partialErrorMessage: partialError));
  }
}
