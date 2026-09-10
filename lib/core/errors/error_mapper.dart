import 'package:dio/dio.dart';
import 'app_exception.dart';

AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      if (statusCode == 401) {
        return UnauthorizedException(_extractTopMessage(responseData) ??
            'Session expired. Please log in again.');
      }
      if (statusCode == 422) {
        final fieldErrors = _extractFieldErrors(responseData);
        if (fieldErrors.isNotEmpty) return ValidationException(fieldErrors);
        return ServerException(
            _extractTopMessage(responseData) ??
                'Please check your information and try again.',
            statusCode: statusCode);
      }
      return ServerException(
          _extractTopMessage(responseData) ??
              _defaultMessageForStatus(statusCode),
          statusCode: statusCode);
    case DioExceptionType.cancel:
      return const AppException('Request was cancelled.');
    default:
      return const AppException('Something went wrong. Please try again.');
  }
}

String? _extractTopMessage(dynamic responseData) {
  if (responseData is Map<String, dynamic> &&
      responseData['message'] is String) {
    return responseData['message'] as String;
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
