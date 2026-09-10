class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'Session expired. Please log in again.']);
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;
  ValidationException(this.fieldErrors) : super(_combine(fieldErrors));
  static String _combine(Map<String, List<String>> fieldErrors) {
    if (fieldErrors.isEmpty) {
      return 'Please check your information and try again.';
    }
    return fieldErrors.entries.map((e) => e.value.join(' ')).join('\n');
  }
}
