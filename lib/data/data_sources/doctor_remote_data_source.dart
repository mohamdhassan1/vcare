import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/core/errors/error_mapper.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/doctor_model.dart';

class DoctorRemoteDataSource {
  DoctorRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<DoctorModel>> getDoctors() async {
    debugPrint('[DOCTORS] Request → GET ${ApiEndpoints.doctors}');
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.doctors);
      debugPrint('[DOCTORS] Response status: ${response.statusCode}');
      debugPrint('[DOCTORS] Raw response: ${response.data}');
      final doctors = DoctorModel.listFromJson(response.data);
      debugPrint('[DOCTORS] Parsed doctor count: ${doctors.length}');
      return doctors;
    } on DioException catch (e) {
      debugPrint(
          '[DOCTORS] DioException status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    } catch (e) {
      debugPrint('[DOCTORS] Unexpected error reading response: $e');
      throw ServerException(
          'Could not read doctor data from the server response: $e',
          code: AppErrorCode.invalidResponse);
    }
  }

  Future<DoctorModel> getDoctorDetails(int id) async {
    debugPrint(
        '[DOCTOR_DETAILS] Request → GET ${ApiEndpoints.doctorDetails(id)} | doctorId:$id');
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.doctorDetails(id));
      debugPrint('[DOCTOR_DETAILS] Response status: ${response.statusCode}');
      debugPrint('[DOCTOR_DETAILS] Raw response: ${response.data}');
      final raw = response.data;
      final data =
          (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>)
              ? raw['data'] as Map<String, dynamic>
              : (raw is Map<String, dynamic> ? raw : <String, dynamic>{});
      final doctor = DoctorModel.fromJson(data);
      debugPrint(
          '[DOCTOR_DETAILS] Parsed: id:${doctor.id} name:${doctor.name}');
      return doctor;
    } on DioException catch (e) {
      debugPrint(
          '[DOCTOR_DETAILS] DioException status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    } catch (e) {
      debugPrint('[DOCTOR_DETAILS] Unexpected error reading response: $e');
      throw ServerException(
          'Could not read doctor details from the server response: $e',
          code: AppErrorCode.invalidResponse);
    }
  }

  Future<List<DoctorModel>> searchDoctors(String name) async {
    debugPrint(
        '[SEARCH] Request → GET ${ApiEndpoints.doctorSearch}?name=$name');
    try {
      final response = await _apiClient.dio
          .get(ApiEndpoints.doctorSearch, queryParameters: {'name': name});
      debugPrint('[SEARCH] Response status: ${response.statusCode}');
      debugPrint('[SEARCH] Raw response: ${response.data}');
      final doctors = DoctorModel.listFromJson(response.data);
      debugPrint('[SEARCH] Parsed doctor count: ${doctors.length}');
      return doctors;
    } on DioException catch (e) {
      debugPrint(
          '[SEARCH] DioException status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    } catch (e) {
      debugPrint('[SEARCH] Unexpected error reading response: $e');
      throw ServerException(
          'Could not read search results from the server response: $e',
          code: AppErrorCode.invalidResponse);
    }
  }
}
