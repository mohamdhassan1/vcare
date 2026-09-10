import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FavoritesStarted extends FavoritesEvent {
  const FavoritesStarted();
}

class FavoriteToggled extends FavoritesEvent {
  final int doctorId;
  const FavoriteToggled(this.doctorId);
  @override
  List<Object?> get props => [doctorId];
}
