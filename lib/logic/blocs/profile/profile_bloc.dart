import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/profile_photo_repository.dart';
import '../../../data/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._userRepository, this._photoRepository)
      : super(const ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfilePhotoRequested>(_onPhotoRequested);
    on<ProfilePhotoRemoved>(_onPhotoRemoved);
  }

  final UserRepository _userRepository;
  final ProfilePhotoRepository _photoRepository;

  Future<void> _onStarted(
      ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());

    final UserProfileModel profile;
    try {
      profile = await _userRepository.getProfile();
    } on AppException catch (e) {
      emit(ProfileError(AppErrorInfo.from(e)));
      return;
    } catch (e) {
      debugPrint('[PROFILE] Unexpected error loading profile: $e');
      emit(const ProfileError(AppErrorInfo.unknown));
      return;
    }

    // The photo is device-local and optional: a problem reading it must
    // not hide the (successfully fetched) profile behind an error view.
    Uint8List? savedPhoto;
    ProfilePhotoError? photoError;
    try {
      savedPhoto = await _photoRepository.loadSavedPhoto();
    } catch (e) {
      debugPrint('[PHOTO] Could not load saved photo: $e');
      photoError = ProfilePhotoError.loadFailed;
    }
    emit(ProfileLoaded(profile,
        localPhotoBytes: savedPhoto, photoError: photoError));
  }

  Future<void> _onPhotoRequested(
      ProfilePhotoRequested event, Emitter<ProfileState> emit) async {
    if (state is! ProfileLoaded) return;

    Uint8List? bytes;
    try {
      bytes = await _photoRepository.pickImage(event.source);
    } catch (e) {
      debugPrint('[PHOTO] Picker failed: $e');
      _emitPhotoError(ProfilePhotoError.pickFailed, emit);
      return;
    }
    if (bytes == null) return; // user cancelled — nothing to report

    // Re-read: the profile may have been refreshed while the picker
    // was open, and we must not resurrect a stale state.
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      await _photoRepository.savePhoto(bytes);
      emit(current.copyWith(localPhotoBytes: bytes));
    } catch (e) {
      debugPrint('[PHOTO] Save failed: $e');
      // Still show the chosen photo for this session, but tell the user
      // it will not survive a restart so they can retry.
      _emitPhotoError(ProfilePhotoError.saveFailed, emit,
          base: current.copyWith(localPhotoBytes: bytes));
    }
  }

  Future<void> _onPhotoRemoved(
      ProfilePhotoRemoved event, Emitter<ProfileState> emit) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    try {
      await _photoRepository.clearPhoto();
      emit(current.copyWith(clearLocalPhoto: true));
    } catch (e) {
      debugPrint('[PHOTO] Remove failed: $e');
      _emitPhotoError(ProfilePhotoError.removeFailed, emit);
    }
  }

  /// Emits an error-free state first so two identical failures in a
  /// row still produce a distinct state change (and thus a listener
  /// notification) for the second one.
  void _emitPhotoError(ProfilePhotoError error, Emitter<ProfileState> emit,
      {ProfileLoaded? base}) {
    final loaded = base ?? state;
    if (loaded is! ProfileLoaded) return;
    emit(loaded.copyWith());
    emit(loaded.copyWith(photoError: error));
  }
}
