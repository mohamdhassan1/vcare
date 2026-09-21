import 'package:dio/dio.dart';
import 'app_exception.dart';

/// Turns a Dio failure into an [AppException] with a stable
/// [AppErrorCode] (localized by the UI) and, when the backend sent a
/// human-readable `message`, that text as [AppException.serverMessage].
AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const AppException('The request took too long. Please try again.',
          code: AppErrorCode.timeout);
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      final serverMessage = _extractTopMessage(responseData);
      if (statusCode == 401) {
        return UnauthorizedException(
            serverMessage ?? 'Session expired. Please log in again.',
            serverMessage);
      }
      if (statusCode == 422) {
        final fieldErrors = _extractFieldErrors(responseData);
        if (fieldErrors.isNotEmpty) return ValidationException(fieldErrors);
        return ServerException(
            serverMessage ?? 'Please check your information and try again.',
            statusCode: statusCode,
            code: AppErrorCode.validation,
            serverMessage: serverMessage);
      }
      return ServerException(
          serverMessage ?? _defaultMessageForStatus(statusCode),
          statusCode: statusCode,
          code: _codeForStatus(statusCode),
          serverMessage: serverMessage);
    case DioExceptionType.cancel:
      return const AppException('Request was cancelled.',
          code: AppErrorCode.cancelled);
    default:
      return const AppException('Something went wrong. Please try again.');
  }
}

String? _extractTopMessage(dynamic responseData) {
  if (responseData is Map<String, dynamic> &&
      responseData['message'] is String) {
    final message = (responseData['message'] as String).trim();
    return message.isEmpty ? null : message;
  }
  return null;
}

Map<String, List<String>> _extractFieldErrors(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) return {};
  final data = responseData['data'];
  if (data is! Map<String, dynamic>) return {};
  final result = <String, List<String>>{};
  data.forEach((field, value) {
    if (value is List) {
      result[field] = value.map((e) => e.toString()).toList();
    } else if (value is String) {
      result[field] = [value];
    }
  });
  return result;
}

AppErrorCode _codeForStatus(int? statusCode) {
  switch (statusCode) {
    case 400:
      return AppErrorCode.badRequest;
    case 403:
      return AppErrorCode.forbidden;
    case 404:
      return AppErrorCode.notFound;
    case 429:
      return AppErrorCode.tooManyRequests;
    default:
      if (statusCode != null && statusCode >= 500) return AppErrorCode.server;
      return AppErrorCode.unknown;
  }
}

String _defaultMessageForStatus(int? statusCode) {
  switch (statusCode) {
    case 400:
      return 'Invalid request. Please check your information.';
    case 403:
      return 'You do not have permission to do that.';
    case 404:
      return 'Requested resource was not found.';
    case 429:
      return 'Too many requests. Please wait a moment and try again.';
    default:
      if (statusCode != null && statusCode >= 500) {
        return 'Server error. Please try again later.';
      }
      return 'Something went wrong. Please try again.';
  }
}
