import 'package:dio/dio.dart';
import 'package:vcare/core/errors/error_mapper.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/city_model.dart';

class CityRemoteDataSource {
  CityRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<CityModel>> getCities() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.cities);
      return CityModel.listFromJson(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<CityModel>> getCitiesByGovernorate(int governorateId) async {
    try {
      final response = await _apiClient.dio
          .get(ApiEndpoints.citiesByGovernorate(governorateId));
      return CityModel.listFromJson(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
