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
  }

  final AuthRepository _authRepository;

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
      emit(AuthFailure(e.message));
    } catch (e) {
      // Safety net: ANY unexpected error still ends the loading state
      // instead of leaving the UI stuck forever.
      debugPrint('[AUTH] sign up UNEXPECTED error: $e');
      emit(const AuthFailure('Something went wrong. Please try again.'));
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
      emit(AuthFailure(e.message));
    } catch (e) {
      debugPrint('[AUTH] sign in UNEXPECTED error: $e');
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthLoggedOut());
    }
  }
}
