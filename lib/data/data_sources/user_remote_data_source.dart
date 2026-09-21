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
      // Status only — the body is the user's PII.
      debugPrint('[PROFILE] RESPONSE status:${response.statusCode}');
      // The model unwraps the envelope itself (data may be a Map or a
      // List), so no cast here — a surprising shape can't throw.
      final profile = UserProfileModel.fromJson(response.data);
      debugPrint('[PROFILE] Parsed: hasName:${profile.hasName} '
          'hasEmail:${profile.email != null} hasPhone:${profile.phone != null} '
          'hasGender:${profile.gender != null}');
      return profile;
    } on DioException catch (e) {
      debugPrint('[PROFILE] RESPONSE ERROR status:${e.response?.statusCode}');
      throw mapDioException(e);
    }
  }

  /// Matches the Postman "Update Profile" field set:
  /// name, email, phone, gender, password.
  ///
  /// `password` is only included when the caller supplies a non-empty
  /// value — sending an empty password on every save could be rejected
  /// by validation or, worse, interpreted as a password change.
  Future<void> updateProfile(
      {required String name,
      required String email,
      required String phone,
      required String gender,
      String? password}) async {
    final sendsPassword = password != null && password.isNotEmpty;
    // Field values are PII — log only which fields are being sent.
    debugPrint('[PROFILE][UPDATE] Request → POST ${ApiEndpoints.updateProfile} '
        '| fields: name,email,phone,gender${sendsPassword ? ',password' : ''}');
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.updateProfile,
        data: FormData.fromMap({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          if (sendsPassword) 'password': password,
        }),
      );
      debugPrint('[PROFILE][UPDATE] Response status:${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PROFILE][UPDATE] Error status:${e.response?.statusCode}');
      throw mapDioException(e);
    }
  }
}
