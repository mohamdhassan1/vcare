import 'package:equatable/equatable.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialization_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final String userName;
  final List<SpecializationModel> specializations;
  final List<DoctorModel> doctors;
  final String? partialErrorMessage;

  const HomeLoaded(
      {required this.userName,
      required this.specializations,
      required this.doctors,
      this.partialErrorMessage});

  @override
  List<Object?> get props =>
      [userName, specializations, doctors, partialErrorMessage];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
