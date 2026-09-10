import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final Set<int> favoriteIds;
  const FavoritesLoaded(this.favoriteIds);

  bool isFavorite(int doctorId) => favoriteIds.contains(doctorId);

  @override
  List<Object?> get props => [favoriteIds];
}
