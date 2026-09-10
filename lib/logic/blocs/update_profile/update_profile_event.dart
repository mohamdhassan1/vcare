import 'package:equatable/equatable.dart';

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();
  @override
  List<Object?> get props => [];
}

class UpdateProfileSubmitted extends UpdateProfileEvent {
  final String name, email, phone, gender;
  const UpdateProfileSubmitted({required this.name, required this.email, required this.phone, required this.gender});
  @override
  List<Object?> get props => [name, email, phone, gender];
}