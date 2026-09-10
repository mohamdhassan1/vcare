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

  Future<void> _onStarted(
      FavoritesStarted event, Emitter<FavoritesState> emit) async {
    final ids = await _repository.getFavoriteIds();
    emit(FavoritesLoaded(ids));
  }

  Future<void> _onToggled(
      FavoriteToggled event, Emitter<FavoritesState> emit) async {
    final ids = await _repository.toggleFavorite(event.doctorId);
    emit(FavoritesLoaded(ids));
  }
}
