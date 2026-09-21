import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String username;
  const AuthSuccess(this.username);

  @override
  List<Object?> get props => [username];
}

class AuthFailure extends AuthState {
  /// Coded failure the UI localizes; `message` is the English fallback.
  final AppErrorInfo error;
  const AuthFailure(this.error);
  String get message => error.message;

  @override
  List<Object?> get props => [error];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

/// The stored token was rejected by the server (HTTP 401) and has been
/// cleared. Distinct from [AuthLoggedOut] so the app can send the user
/// straight to Sign In (with an explanation) instead of Onboarding.
class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}
