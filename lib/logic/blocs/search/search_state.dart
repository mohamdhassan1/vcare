import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialization_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<DoctorModel> doctors;
  final List<SpecializationModel> specializations;
  final int? selectedSpecializationId;
  final String query;

  const SearchLoaded({
    required this.doctors,
    required this.specializations,
    required this.selectedSpecializationId,
    required this.query,
  });

  /// Client-side filter — no API param exists for this, so results
  /// already fetched from the real search/list endpoint are filtered
  /// locally by matching specialization name. Never presented as a
  /// server operation.
  List<DoctorModel> get visibleDoctors {
    if (selectedSpecializationId == null) return doctors;
    final selectedName = specializations
        .firstWhere((s) => s.id == selectedSpecializationId,
            orElse: () => const SpecializationModel(id: -1, name: ''))
        .name
        .toLowerCase();
    if (selectedName.isEmpty) return doctors;
    return doctors
        .where((d) =>
            (d.specialization ?? '').toLowerCase().contains(selectedName))
        .toList();
  }

  SearchLoaded copyWith({
    List<DoctorModel>? doctors,
    List<SpecializationModel>? specializations,
    int? selectedSpecializationId,
    bool clearSelectedSpecializationId = false,
    String? query,
  }) {
    return SearchLoaded(
      doctors: doctors ?? this.doctors,
      specializations: specializations ?? this.specializations,
      selectedSpecializationId: clearSelectedSpecializationId
          ? null
          : (selectedSpecializationId ?? this.selectedSpecializationId),
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props =>
      [doctors, specializations, selectedSpecializationId, query];
}

class SearchError extends SearchState {
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const SearchError(this.error);
  String get message => error.message;
  @override
  List<Object?> get props => [error];
}
