import 'package:equatable/equatable.dart';

/// Which favorites operation failed. A code rather than a message so
/// the UI can show a localized string and the bloc stays free of
/// user-facing text.
enum FavoritesErrorType { loadFailed, toggleFailed }

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  /// The last known favorite IDs. Empty while loading (or when nobody
  /// is signed in); kept on [FavoritesError] so an unrelated failure
  /// doesn't make already-loaded hearts disappear.
  Set<int> get favoriteIds => const <int>{};

  bool isFavorite(int doctorId) => favoriteIds.contains(doctorId);

  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  @override
  final Set<int> favoriteIds;
  const FavoritesLoaded(this.favoriteIds);

  @override
  List<Object?> get props => [favoriteIds];
}

/// A load or toggle failed. [favoriteIds] is the best-known set at the
/// time of the failure (empty for a failed load) so the UI can keep
/// rendering it; the user can retry by reloading / tapping again.
class FavoritesError extends FavoritesState {
  final FavoritesErrorType type;
  @override
  final Set<int> favoriteIds;
  const FavoritesError(this.type, {this.favoriteIds = const <int>{}});

  @override
  List<Object?> get props => [type, favoriteIds];
}
