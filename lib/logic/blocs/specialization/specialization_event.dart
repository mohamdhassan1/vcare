import 'package:equatable/equatable.dart';

abstract class SpecializationEvent extends Equatable {
  const SpecializationEvent();
  @override
  List<Object?> get props => [];
}

class SpecializationListStarted extends SpecializationEvent {
  const SpecializationListStarted();
}
