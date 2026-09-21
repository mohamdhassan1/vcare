import '../../core/api/token_storage.dart';
import '../data_sources/favorites_local_data_source.dart';

/// Device-local favorites, scoped to the signed-in account.
///
/// The account is identified by the normalised email saved by
/// AuthRepository at login/register (see TokenStorage.saveUserEmail).
/// A token must also be present: after logout or a 401 the token is
/// gone, so favorites resolve to an empty set even if an email were
/// still stored — the previous user's hearts can never show up for
/// whoever signs in next.
class FavoritesRepository {
  FavoritesRepository(this._localDataSource, this._tokenStorage);
  final FavoritesLocalDataSource _localDataSource;
  final TokenStorage _tokenStorage;

  /// Storage key of the current account, or null when nobody is
  /// signed in.
  Future<String?> _currentUserKey() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) return null;
    final email = await _tokenStorage.getUserEmail();
    if (email == null || email.trim().isEmpty) return null;
    return email.trim().toLowerCase();
  }

  Future<Set<int>> getFavoriteIds() async {
    final userKey = await _currentUserKey();
    if (userKey == null) return <int>{};
    return _localDataSource.getFavoriteIds(userKey);
  }

  /// Returns the updated set. Throws (instead of pretending it worked)
  /// when no account is signed in or the storage write fails; the bloc
  /// reports that as a failed toggle.
  Future<Set<int>> toggleFavorite(int doctorId) async {
    final userKey = await _currentUserKey();
    if (userKey == null) {
      throw StateError('Cannot change favorites: no signed-in user.');
    }
    final current = await _localDataSource.getFavoriteIds(userKey);
    if (current.contains(doctorId)) {
      current.remove(doctorId);
    } else {
      current.add(doctorId);
    }
    await _localDataSource.saveFavoriteIds(userKey, current);
    return current;
  }
}
