import 'package:equatable/equatable.dart';

abstract class UpdateProfileState extends Equatable {
  const UpdateProfileState();
  @override
  List<Object?> get props => [];
}

class UpdateProfileInitial extends UpdateProfileState {
  const UpdateProfileInitial();
}

class UpdateProfileSubmitting extends UpdateProfileState {
  const UpdateProfileSubmitting();
}

class UpdateProfileSuccess extends UpdateProfileState {
  const UpdateProfileSuccess();
}

class UpdateProfileFailure extends UpdateProfileState {
  final String message;
  const UpdateProfileFailure(this.message);
  @override
  List<Object?> get props => [message];
}