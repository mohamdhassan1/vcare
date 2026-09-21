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

  /// Bloc runs event handlers concurrently by default, so when the user
  /// types "A", "AB", "ABC" three requests are in flight at once and
  /// each would emit whenever *its* response arrives — a slow "A" could
  /// land last and overwrite the "ABC" results. Every request takes a
  /// ticket from this counter; only the holder of the newest ticket is
  /// allowed to emit. (Same effect as bloc_concurrency's restartable(),
  /// without adding a dependency.)
  int _latestRequestId = 0;

  int _nextRequestId() => ++_latestRequestId;
  bool _isStale(int requestId) => requestId != _latestRequestId;

  Future<void> _onOpened(SearchOpened event, Emitter<SearchState> emit) async {
    final requestId = _nextRequestId();
    emit(const SearchLoading());
    try {
      final doctors = await _doctorRepository.getDoctors();
      final specializations =
          await _specializationRepository.getSpecializations();
      if (_isStale(requestId)) return;
      // A requested specialty that the server list does not contain is
      // ignored, so the filter can never hide every doctor by mistake.
      final knownId = specializations.any((s) => s.id == event.specializationId)
          ? event.specializationId
          : null;
      emit(SearchLoaded(
          doctors: doctors,
          specializations: specializations,
          selectedSpecializationId: knownId,
          query: ''));
    } on AppException catch (e) {
      if (_isStale(requestId)) return;
      emit(SearchError(AppErrorInfo.from(e)));
    } catch (e) {
      if (_isStale(requestId)) return;
      emit(const SearchError(AppErrorInfo.unknown));
    }
  }

  Future<void> _onQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    final requestId = _nextRequestId();
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
      // A newer query was issued while we were waiting: drop this
      // result so it can never replace the newer one.
      if (_isStale(requestId)) return;
      emit(SearchLoaded(
        doctors: doctors,
        specializations: specializations,
        selectedSpecializationId: previousSelectedId,
        query: event.query,
      ));
    } on AppException catch (e) {
      if (_isStale(requestId)) return;
      emit(SearchError(AppErrorInfo.from(e)));
    } catch (e) {
      if (_isStale(requestId)) return;
      emit(const SearchError(AppErrorInfo.unknown));
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
