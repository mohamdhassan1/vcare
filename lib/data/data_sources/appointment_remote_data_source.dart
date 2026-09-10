import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_mapper.dart';
import '../models/appointment_list_item_model.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDataSource {
  AppointmentRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<AppointmentModel> storeAppointment({
    required int doctorId,
    required String startTime,
    String? notes,
  }) async {
    debugPrint(
        '[APPOINTMENT] Request → POST ${ApiEndpoints.storeAppointment} | doctor_id:$doctorId start_time:$startTime');
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.storeAppointment,
        data: FormData.fromMap({
          'doctor_id': doctorId.toString(),
          'start_time': startTime,
          'notes': notes ?? '',
        }),
      );
      debugPrint('[APPOINTMENT] Response status: ${response.statusCode}');
      debugPrint('[APPOINTMENT] Raw response: ${response.data}');
      return AppointmentModel.fromJson(response.data,
          doctorId: doctorId, startTime: startTime, notes: notes);
    } on DioException catch (e) {
      debugPrint(
          '[APPOINTMENT] DioException status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    }
  }

  Future<List<AppointmentListItemModel>> getAppointments() async {
    debugPrint('[APPOINTMENTS] Request → GET ${ApiEndpoints.appointments}');
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.appointments);
      debugPrint('[APPOINTMENTS] Response status: ${response.statusCode}');
      debugPrint('[APPOINTMENTS] Raw response: ${response.data}');
      final items = AppointmentListItemModel.listFromJson(response.data);
      debugPrint('[APPOINTMENTS] Parsed count: ${items.length}');
      return items;
    } on DioException catch (e) {
      debugPrint(
          '[APPOINTMENTS] DioException status:${e.response?.statusCode} body:${e.response?.data}');
      throw mapDioException(e);
    } catch (e) {
      debugPrint('[APPOINTMENTS] Unexpected error reading response: $e');
      throw ServerException(
          'Could not read appointment data from the server response: $e');
    }
  }
}
