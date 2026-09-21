import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(this._repository) : super(const FavoritesLoading()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoriteToggled>(_onToggled);
  }

  final FavoritesRepository _repository;

  /// Loads the signed-in account's favorites. Dispatched at app start
  /// and again whenever the session changes (login, logout, expiry) so
  /// the in-memory set always belongs to the current user.
  Future<void> _onStarted(
      FavoritesStarted event, Emitter<FavoritesState> emit) async {
    // Loading clears the previous user's IDs immediately; nothing from
    // the old session can be shown while the new one is read.
    emit(const FavoritesLoading());
    try {
      final ids = await _repository.getFavoriteIds();
      emit(FavoritesLoaded(ids));
    } catch (e) {
      debugPrint('[FAVORITES] Load failed: $e');
      emit(const FavoritesError(FavoritesErrorType.loadFailed));
    }
  }

  Future<void> _onToggled(
      FavoriteToggled event, Emitter<FavoritesState> emit) async {
    final previous = state.favoriteIds;
    try {
      final ids = await _repository.toggleFavorite(event.doctorId);
      emit(FavoritesLoaded(ids));
    } catch (e) {
      debugPrint('[FAVORITES] Toggle failed for ${event.doctorId}: $e');
      // Keep showing what we last knew — the tap did not take effect —
      // and emit the error as a separate transition so a listener fires
      // even if the exact same failure just happened.
      emit(FavoritesLoaded(previous));
      emit(FavoritesError(FavoritesErrorType.toggleFailed,
          favoriteIds: previous));
    }
  }
}
