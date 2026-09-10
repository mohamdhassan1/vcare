import 'package:equatable/equatable.dart';
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
  final String message;
  const SpecializationError(this.message);
  @override
  List<Object?> get props => [message];
}
