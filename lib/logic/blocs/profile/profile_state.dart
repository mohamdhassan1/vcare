import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_profile_model.dart';

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
  final Uint8List? localPhotoBytes;

  const ProfileLoaded(this.profile, {this.localPhotoBytes});

  ProfileLoaded copyWith({Uint8List? localPhotoBytes}) {
    return ProfileLoaded(profile, localPhotoBytes: localPhotoBytes ?? this.localPhotoBytes);
  }

  @override
  List<Object?> get props => [profile, localPhotoBytes];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}