import 'package:dio/dio.dart';
import 'package:vcare/core/errors/error_mapper.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/governorate_model.dart';

class GovernorateRemoteDataSource {
  GovernorateRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<GovernorateModel>> getGovernorates() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.governorates);
      return GovernorateModel.listFromJson(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
