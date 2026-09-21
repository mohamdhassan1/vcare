import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/user_profile_model.dart';

/// What went wrong with the device-local profile photo. A code rather
/// than a message so the UI can show a localized string and the bloc
/// stays free of user-facing text.
enum ProfilePhotoError { loadFailed, pickFailed, saveFailed, removeFailed }

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;

  /// Device-local photo (never uploaded). Null when none is saved.
  final Uint8List? localPhotoBytes;

  /// Transient: set on the state emitted right after a photo operation
  /// fails, and dropped by the next [copyWith] unless re-supplied, so a
  /// listener sees each failure exactly once.
  final ProfilePhotoError? photoError;

  const ProfileLoaded(this.profile, {this.localPhotoBytes, this.photoError});

  ProfileLoaded copyWith({
    Uint8List? localPhotoBytes,
    bool clearLocalPhoto = false,
    ProfilePhotoError? photoError,
  }) {
    return ProfileLoaded(
      profile,
      localPhotoBytes:
          clearLocalPhoto ? null : (localPhotoBytes ?? this.localPhotoBytes),
      photoError: photoError,
    );
  }

  @override
  List<Object?> get props => [profile, localPhotoBytes, photoError];
}

class ProfileError extends ProfileState {
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const ProfileError(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
