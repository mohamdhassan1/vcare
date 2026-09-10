import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/profile_photo_repository.dart';
import '../../../data/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._userRepository, this._photoRepository)
      : super(const ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfilePhotoRequested>(_onPhotoRequested);
  }

  final UserRepository _userRepository;
  final ProfilePhotoRepository _photoRepository;

  Future<void> _onStarted(
      ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final profile = await _userRepository.getProfile();
      final savedPhoto = await _photoRepository.loadSavedPhoto();
      emit(ProfileLoaded(profile, localPhotoBytes: savedPhoto));
    } on AppException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(const ProfileError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onPhotoRequested(
      ProfilePhotoRequested event, Emitter<ProfileState> emit) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    try {
      final bytes = await _photoRepository.pickImage(event.source);
      if (bytes != null) emit(current.copyWith(localPhotoBytes: bytes));
    } catch (_) {}
  }
}
