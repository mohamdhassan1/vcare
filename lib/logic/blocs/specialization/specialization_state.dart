import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/specialization_model.dart';

abstract class SpecializationState extends Equatable {
  const SpecializationState();
  @override
  List<Object?> get props => [];
}

class SpecializationLoading extends SpecializationState {
  const SpecializationLoading();
}

class SpecializationLoaded extends SpecializationState {
  final List<SpecializationModel> specializations;
  const SpecializationLoaded(this.specializations);
  @override
  List<Object?> get props => [specializations];
}

class SpecializationError extends SpecializationState {
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const SpecializationError(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
