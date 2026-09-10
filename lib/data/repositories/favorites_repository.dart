import '../data_sources/favorites_local_data_source.dart';

class FavoritesRepository {
  FavoritesRepository(this._localDataSource);
  final FavoritesLocalDataSource _localDataSource;

  Future<Set<int>> getFavoriteIds() => _localDataSource.getFavoriteIds();

  Future<Set<int>> toggleFavorite(int doctorId) async {
    final current = await _localDataSource.getFavoriteIds();
    if (current.contains(doctorId)) {
      current.remove(doctorId);
    } else {
      current.add(doctorId);
    }
    await _localDataSource.saveFavoriteIds(current);
    return current;
  }
}
