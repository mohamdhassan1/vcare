// B8 / B12 — favorites are scoped to the signed-in account and storage
// failures become recoverable error states instead of a stuck spinner.

import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/api/token_storage.dart';
import 'package:vcare/data/data_sources/favorites_local_data_source.dart';
import 'package:vcare/data/repositories/favorites_repository.dart';
import 'package:vcare/logic/blocs/favorites/favorites_bloc.dart';
import 'package:vcare/logic/blocs/favorites/favorites_event.dart';
import 'package:vcare/logic/blocs/favorites/favorites_state.dart';

/// In-memory stand-in for secure storage, mirroring what AuthRepository
/// writes on login and clears on logout.
class _FakeTokenStorage implements TokenStorage {
  String? token;
  String? username;
  String? email;

  void signIn(String userEmail) {
    token = 'token-for-$userEmail';
    email = userEmail;
  }

  void signOut() {
    token = null;
    email = null;
  }

  @override
  Future<void> saveToken(String value) async => token = value;
  @override
  Future<String?> getToken() async => token;
  @override
  Future<void> clearToken() async => token = null;
  @override
  Future<void> saveUsername(String value) async => username = value;
  @override
  Future<String?> getUsername() async => username;
  @override
  Future<void> saveUserEmail(String value) async => email = value;
  @override
  Future<String?> getUserEmail() async => email;
  @override
  Future<void> clearUserEmail() async => email = null;
}

/// In-memory per-user store with switchable failure modes.
class _InMemoryFavoritesDataSource implements FavoritesLocalDataSource {
  final Map<String, Set<int>> store = {};
  bool failReads = false;
  bool failWrites = false;

  @override
  Future<Set<int>> getFavoriteIds(String userKey) async {
    if (failReads) throw Exception('storage read failed');
    return Set<int>.of(store[userKey] ?? const <int>{});
  }

  @override
  Future<void> saveFavoriteIds(String userKey, Set<int> ids) async {
    if (failWrites) throw Exception('storage write failed');
    store[userKey] = Set<int>.of(ids);
  }
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  group('FavoritesLocalDataSource encoding', () {
    test('round-trips a per-user map', () {
      final encoded = FavoritesLocalDataSource.encode({
        'a@x.com': {3, 1},
        'b@x.com': {2},
      });
      final decoded = FavoritesLocalDataSource.decode(encoded);
      expect(decoded['a@x.com'], {1, 3});
      expect(decoded['b@x.com'], {2});
    });

    test('ignores the legacy unowned "1,2,3" format and corrupt data', () {
      expect(FavoritesLocalDataSource.decode('1,2,3'), isEmpty);
      expect(FavoritesLocalDataSource.decode('{not json'), isEmpty);
      expect(FavoritesLocalDataSource.decode('[1,2]'), isEmpty);
      expect(FavoritesLocalDataSource.decode(null), isEmpty);
      expect(FavoritesLocalDataSource.decode(''), isEmpty);
    });

    test('drops non-integer entries and empty users', () {
      final decoded = FavoritesLocalDataSource.decode(
          '{"a@x.com":[1,"x",2.0,null],"empty@x.com":[],"bad@x.com":"1"}');
      expect(decoded, {
        'a@x.com': {1, 2}
      });
    });
  });

  group('FavoritesRepository account isolation', () {
    late _FakeTokenStorage tokens;
    late _InMemoryFavoritesDataSource storage;
    late FavoritesRepository repository;

    setUp(() {
      tokens = _FakeTokenStorage();
      storage = _InMemoryFavoritesDataSource();
      repository = FavoritesRepository(storage, tokens);
    });

    test('user B never sees user A favorites; A gets them back later',
        () async {
      tokens.signIn('a@x.com');
      await repository.toggleFavorite(1);
      await repository.toggleFavorite(2);
      expect(await repository.getFavoriteIds(), {1, 2});

      tokens.signOut();
      expect(await repository.getFavoriteIds(), isEmpty,
          reason: 'nobody signed in → nothing to show');

      tokens.signIn('b@x.com');
      expect(await repository.getFavoriteIds(), isEmpty,
          reason: 'B must not inherit A\'s hearts');
      await repository.toggleFavorite(3);
      expect(await repository.getFavoriteIds(), {3});

      tokens.signOut();
      tokens.signIn('a@x.com');
      expect(await repository.getFavoriteIds(), {1, 2},
          reason: 'A\'s favorites survive the account switch');

      // Both accounts remain stored side by side.
      expect(storage.store['a@x.com'], {1, 2});
      expect(storage.store['b@x.com'], {3});
    });

    test('a stale email without a token (401 / expiry) yields no favorites',
        () async {
      tokens.signIn('a@x.com');
      await repository.toggleFavorite(1);
      // Phase 1A interceptor clears only the token on 401.
      tokens.token = null;
      expect(await repository.getFavoriteIds(), isEmpty);
      expect(() => repository.toggleFavorite(2), throwsStateError);
    });

    test('email is normalised so casing/whitespace map to one account',
        () async {
      tokens.signIn('a@x.com');
      await repository.toggleFavorite(1);
      tokens.signIn('  A@X.COM ');
      expect(await repository.getFavoriteIds(), {1});
    });

    test('toggle removes an existing favorite', () async {
      tokens.signIn('a@x.com');
      await repository.toggleFavorite(1);
      expect(await repository.toggleFavorite(1), isEmpty);
    });
  });

  group('FavoritesBloc error handling', () {
    late _FakeTokenStorage tokens;
    late _InMemoryFavoritesDataSource storage;
    late FavoritesBloc bloc;

    setUp(() {
      tokens = _FakeTokenStorage()..signIn('a@x.com');
      storage = _InMemoryFavoritesDataSource();
      bloc = FavoritesBloc(FavoritesRepository(storage, tokens));
    });

    tearDown(() => bloc.close());

    test('loads the correct user\'s favorites', () async {
      storage.store['a@x.com'] = {5};
      storage.store['b@x.com'] = {9};
      bloc.add(const FavoritesStarted());
      await _settle();
      expect(bloc.state, const FavoritesLoaded({5}));
      expect(bloc.state.isFavorite(5), isTrue);
      expect(bloc.state.isFavorite(9), isFalse);
    });

    test('a read failure ends in an error state, not permanent loading',
        () async {
      storage.failReads = true;
      bloc.add(const FavoritesStarted());
      await _settle();
      expect(bloc.state, isA<FavoritesError>());
      expect(
          (bloc.state as FavoritesError).type, FavoritesErrorType.loadFailed);
      expect(bloc.state.favoriteIds, isEmpty);

      // Retry after the problem goes away.
      storage.failReads = false;
      storage.store['a@x.com'] = {1};
      bloc.add(const FavoritesStarted());
      await _settle();
      expect(bloc.state, const FavoritesLoaded({1}));
    });

    test('a failed toggle keeps the previous set and reports the failure',
        () async {
      storage.store['a@x.com'] = {1};
      bloc.add(const FavoritesStarted());
      await _settle();

      storage.failWrites = true;
      bloc.add(const FavoriteToggled(2));
      await _settle();

      final state = bloc.state;
      expect(state, isA<FavoritesError>());
      expect((state as FavoritesError).type, FavoritesErrorType.toggleFailed);
      expect(state.isFavorite(1), isTrue, reason: 'existing hearts stay');
      expect(state.isFavorite(2), isFalse, reason: 'no fake success');

      // Tapping again once storage works succeeds.
      storage.failWrites = false;
      bloc.add(const FavoriteToggled(2));
      await _settle();
      expect(bloc.state, const FavoritesLoaded({1, 2}));
    });

    test('reloading after switching accounts drops the old user\'s set',
        () async {
      storage.store['a@x.com'] = {1};
      bloc.add(const FavoritesStarted());
      await _settle();
      expect(bloc.state.isFavorite(1), isTrue);

      tokens.signOut();
      tokens.signIn('b@x.com');
      bloc.add(const FavoritesStarted());
      await _settle();
      expect(bloc.state, const FavoritesLoaded({}));
      expect(bloc.state.isFavorite(1), isFalse);
    });
  });
}
