/// Stable identifiers for the failures the app knows how to explain.
/// The UI maps these to localized text (see `context.errorText`), so the
/// English `message` on [AppException] is only a developer/log fallback.
enum AppErrorCode {
  unknown,
  network,
  timeout,
  cancelled,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  tooManyRequests,
  server,
  validation,
  invalidResponse,

  // AI assistant (Gemini) specific.
  aiNotConfigured,
  aiInvalidKey,
  aiRateLimited,
  aiTimeout,
  aiServiceError,
  aiBlocked,
  aiEmptyResponse,
  aiInvalidRequest,
}

class AppException implements Exception {
  /// English text for logs, tests and as a last-resort fallback.
  final String message;

  /// What kind of failure this is — the UI localizes from this.
  final AppErrorCode code;

  /// Human-readable text the backend itself sent (e.g. a Laravel
  /// validation message). Shown as-is when present for codes where the
  /// server's wording is the most useful thing we have; never translated.
  final String? serverMessage;

  const AppException(this.message,
      {this.code = AppErrorCode.unknown, this.serverMessage});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.'])
      : super(code: AppErrorCode.network);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message,
      {this.statusCode, super.code = AppErrorCode.server, super.serverMessage});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'Session expired. Please log in again.',
      String? serverMessage])
      : super(code: AppErrorCode.unauthorized, serverMessage: serverMessage);
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;
  ValidationException(this.fieldErrors)
      : super(_combine(fieldErrors),
            code: AppErrorCode.validation,
            serverMessage: fieldErrors.isEmpty ? null : _combine(fieldErrors));
  static String _combine(Map<String, List<String>> fieldErrors) {
    if (fieldErrors.isEmpty) {
      return 'Please check your information and try again.';
    }
    return fieldErrors.entries.map((e) => e.value.join(' ')).join('\n');
  }
}

/// Immutable, state-friendly snapshot of a failure for BLoC states.
/// Built from any thrown object so blocs never leak raw exceptions and
/// the UI always has a code to localize.
class AppErrorInfo {
  final AppErrorCode code;
  final String message;
  final String? serverMessage;

  const AppErrorInfo(this.code, this.message, {this.serverMessage});

  /// Generic catch-all used when something non-AppException is thrown.
  static const AppErrorInfo unknown = AppErrorInfo(
      AppErrorCode.unknown, 'Something went wrong. Please try again.');

  factory AppErrorInfo.from(Object error) {
    if (error is AppException) {
      return AppErrorInfo(error.code, error.message,
          serverMessage: error.serverMessage);
    }
    return unknown;
  }

  @override
  bool operator ==(Object other) =>
      other is AppErrorInfo &&
      other.code == code &&
      other.message == message &&
      other.serverMessage == serverMessage;

  @override
  int get hashCode => Object.hash(code, message, serverMessage);

  @override
  String toString() => 'AppErrorInfo($code, $message)';
}
