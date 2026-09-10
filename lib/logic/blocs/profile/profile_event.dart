import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfilePhotoRequested extends ProfileEvent {
  final ImageSource source;
  const ProfilePhotoRequested(this.source);
  @override
  List<Object?> get props => [source];
}