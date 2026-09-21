import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';

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
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const UpdateProfileFailure(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
