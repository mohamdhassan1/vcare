import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);

    // The API layer reports rejected tokens here so session expiry is
    // handled once, app-wide, instead of by whichever screen happened
    // to make the failing request.
    _sessionExpiredSubscription = _authRepository.sessionExpired
        .listen((_) => add(const SessionExpired()));
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  @override
  Future<void> close() {
    _sessionExpiredSubscription.cancel();
    return super.close();
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final username = await _authRepository.register(
        name: event.name,
        email: event.email,
        phone: event.phone,
        gender: event.gender,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      debugPrint('[AUTH] sign up success: $username');
      emit(AuthSuccess(username));
    } on AppException catch (e) {
      debugPrint('[AUTH] sign up failure: ${e.message}');
      emit(AuthFailure(AppErrorInfo.from(e)));
    } catch (e) {
      // Safety net: ANY unexpected error still ends the loading state
      // instead of leaving the UI stuck forever.
      debugPrint('[AUTH] sign up UNEXPECTED error: $e');
      emit(const AuthFailure(AppErrorInfo.unknown));
    }
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final username = await _authRepository.login(
          email: event.email, password: event.password);
      debugPrint('[AUTH] sign in success: $username');
      emit(AuthSuccess(username));
    } on AppException catch (e) {
      debugPrint('[AUTH] sign in failure: ${e.message}');
      emit(AuthFailure(AppErrorInfo.from(e)));
    } catch (e) {
      debugPrint('[AUTH] sign in UNEXPECTED error: $e');
      emit(const AuthFailure(AppErrorInfo.unknown));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
    } catch (e) {
      // The repository already swallows server failures; this only
      // guards local-storage errors so logout can never throw out of
      // the bloc or leave the UI without an AuthLoggedOut transition.
      debugPrint('[AUTH] logout UNEXPECTED error: $e');
    }
    emit(const AuthLoggedOut());
  }

  void _onSessionExpired(SessionExpired event, Emitter<AuthState> emit) {
    // Several in-flight requests can 401 at almost the same moment;
    // only the first transition matters. Also ignore stragglers that
    // arrive after the user already logged out on purpose.
    if (state is AuthSessionExpired || state is AuthLoggedOut) return;
    debugPrint('[AUTH] session expired — returning to sign in');
    emit(const AuthSessionExpired());
  }
}
