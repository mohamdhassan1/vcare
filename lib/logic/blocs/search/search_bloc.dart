import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/models/specialization_model.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../data/repositories/specialization_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._doctorRepository, this._specializationRepository)
      : super(const SearchLoading()) {
    on<SearchOpened>(_onOpened);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSpecialtyFilterSelected>(_onSpecialtyFilterSelected);
  }

  final DoctorRepository _doctorRepository;
  final SpecializationRepository _specializationRepository;

  Future<void> _onOpened(SearchOpened event, Emitter<SearchState> emit) async {
    emit(const SearchLoading());
    try {
      final doctors = await _doctorRepository.getDoctors();
      final specializations =
          await _specializationRepository.getSpecializations();
      emit(SearchLoaded(
          doctors: doctors,
          specializations: specializations,
          selectedSpecializationId: null,
          query: ''));
    } on AppException catch (e) {
      emit(SearchError(e.message));
    } catch (e) {
      emit(const SearchError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    final current = state;
    final List<SpecializationModel> previousSpecializations =
        current is SearchLoaded
            ? current.specializations
            : <SpecializationModel>[];
    final int? previousSelectedId =
        current is SearchLoaded ? current.selectedSpecializationId : null;

    emit(const SearchLoading());
    try {
      final doctors = event.query.trim().isEmpty
          ? await _doctorRepository.getDoctors()
          : await _doctorRepository.searchDoctors(event.query.trim());
      final specializations = previousSpecializations.isNotEmpty
          ? previousSpecializations
          : await _specializationRepository.getSpecializations();
      emit(SearchLoaded(
        doctors: doctors,
        specializations: specializations,
        selectedSpecializationId: previousSelectedId,
        query: event.query,
      ));
    } on AppException catch (e) {
      emit(SearchError(e.message));
    } catch (e) {
      emit(const SearchError('Something went wrong. Please try again.'));
    }
  }

  void _onSpecialtyFilterSelected(
      SearchSpecialtyFilterSelected event, Emitter<SearchState> emit) {
    final current = state;
    if (current is! SearchLoaded) return;
    // Purely local — no new API call, since no server-side specialization filter exists.
    emit(current.copyWith(
      selectedSpecializationId: event.specializationId,
      clearSelectedSpecializationId: event.specializationId == null,
    ));
  }
}
