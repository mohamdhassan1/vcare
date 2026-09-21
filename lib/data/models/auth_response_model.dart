import 'package:vcare/core/errors/app_exception.dart';

class AuthResponseModel {
  final String token;
  final String username;
  const AuthResponseModel({required this.token, required this.username});

  factory AuthResponseModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const ServerException(
          'Unexpected response from server. Please try again.',
          code: AppErrorCode.invalidResponse);
    }
    final rawData = json['data'];
    if (rawData is! Map<String, dynamic>) {
      throw const ServerException(
          'Unexpected response from server. Please try again.',
          code: AppErrorCode.invalidResponse);
    }
    final token = rawData['token'];
    if (token is! String || token.isEmpty) {
      throw const ServerException(
          'Login response did not include a valid session token.',
          code: AppErrorCode.invalidResponse);
    }
    final username = rawData['username'];
    return AuthResponseModel(
        token: token,
        username:
            (username is String && username.isNotEmpty) ? username : 'User');
  }
}
