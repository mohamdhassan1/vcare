import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/core/errors/error_mapper.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/specialization_model.dart';

class SpecializationRemoteDataSource {
  SpecializationRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<SpecializationModel>> getSpecializations() async {
    debugPrint(
        '[SPECIALIZATIONS] Request → GET ${ApiEndpoints.specializations}');
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.specializations);
      debugPrint('[SPECIALIZATIONS] Response status: ${response.statusCode}');
      debugPrint('[SPECIALIZATIONS] Raw response: ${response.data}');
      final items = SpecializationModel.listFromJson(response.data);
      debugPrint('[SPECIALIZATIONS] Parsed count: ${items.length}');
      return items;
    } on DioException catch (e) {
      debugPrint(
          '[SPECIALIZATIONS] DioException status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    } catch (e) {
      debugPrint('[SPECIALIZATIONS] Unexpected error reading response: $e');
      throw ServerException(
          'Could not read specialization data from the server response: $e');
    }
  }
}
