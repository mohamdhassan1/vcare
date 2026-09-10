import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcare/core/errors/error_mapper.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
    required String passwordConfirmation,
  }) async {
    debugPrint(
        '[AUTH][SIGNUP] Request: name:$name email:$email phone:$phone gender:$gender');
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.register,
          data: FormData.fromMap({
            'name': name,
            'email': email,
            'phone': phone,
            'gender': gender,
            'password': password,
            'password_confirmation': passwordConfirmation,
          }));
      debugPrint('[AUTH][SIGNUP] Response status: ${response.statusCode}');
      final result = AuthResponseModel.fromJson(response.data);
      debugPrint('[AUTH][SIGNUP] Token received: ${result.token.isNotEmpty}');
      return result;
    } on DioException catch (e) {
      debugPrint('[AUTH][SIGNUP] Response status: ${e.response?.statusCode}');
      debugPrint('[AUTH][SIGNUP] Response body: ${e.response?.data}');
      throw mapDioException(e);
    }
  }

  Future<AuthResponseModel> login(
      {required String email, required String password}) async {
    debugPrint('[AUTH][LOGIN] Request: email:$email');
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.login,
          data: FormData.fromMap({
            'email': email,
            'password': password,
          }));
      debugPrint('[AUTH][LOGIN] Response status: ${response.statusCode}');
      final result = AuthResponseModel.fromJson(response.data);
      debugPrint('[AUTH][LOGIN] Token received: ${result.token.isNotEmpty}');
      return result;
    } on DioException catch (e) {
      debugPrint('[AUTH][LOGIN] Response status: ${e.response?.statusCode}');
      debugPrint('[AUTH][LOGIN] Response body: ${e.response?.data}');
      throw mapDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
