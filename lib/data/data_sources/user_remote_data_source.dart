import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/errors/error_mapper.dart';
import '../models/user_profile_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<UserProfileModel> getProfile() async {
    debugPrint('[PROFILE] REQUEST → GET ${ApiEndpoints.userProfile}');
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.userProfile);
      debugPrint(
          '[PROFILE] RESPONSE status:${response.statusCode} body:${response.data}');
      final profile =
          UserProfileModel.fromJson(response.data as Map<String, dynamic>);
      return profile;
    } on DioException catch (e) {
      debugPrint(
          '[PROFILE] RESPONSE ERROR status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    }
  }

  /// Matches the exact Postman "Update Profile" field set:
  /// name, email, phone, gender, password. Password sent empty when
  /// the user isn't changing it — matches every disabled/optional
  /// field pattern already used by /auth/register in this project.
  Future<void> updateProfile(
      {required String name,
      required String email,
      required String phone,
      required String gender,
      String password = ''}) async {
    debugPrint(
        '[PROFILE][UPDATE] Request → POST ${ApiEndpoints.updateProfile} | name:$name email:$email phone:$phone gender:$gender');
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.updateProfile,
        data: FormData.fromMap({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'password': password
        }),
      );
      debugPrint(
          '[PROFILE][UPDATE] Response status:${response.statusCode} body:${response.data}');
    } on DioException catch (e) {
      debugPrint(
          '[PROFILE][UPDATE] Error status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    }
  }
}
