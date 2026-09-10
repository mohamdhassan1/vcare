import 'package:flutter/foundation.dart';
import '../../core/utils/json_list_extractor.dart';

class AppointmentListItemModel {
  final int id;
  final String? doctorName;
  final String? specialization;
  final String? appointmentTime;
  final String? status;
  final String? doctorImageUrl;
  final num? price;

  const AppointmentListItemModel({
    required this.id,
    this.doctorName,
    this.specialization,
    this.appointmentTime,
    this.status,
    this.doctorImageUrl,
    this.price,
  });

  factory AppointmentListItemModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'];
    final doctorMap = doctor is Map<String, dynamic> ? doctor : null;
    return AppointmentListItemModel(
      id: _parseId(json['id']),
      doctorName: (doctorMap?['name'] ?? json['doctor_name']) as String?,
      specialization: _extractName(doctorMap?['specialization']),
      appointmentTime: (json['appointment_time'] ?? json['start_time'] ?? json['date']) as String?,
      status: json['status'] as String?,
      doctorImageUrl: (doctorMap?['photo'] ?? doctorMap?['image']) as String?,
      price: json['appoint_price'] is num ? json['appoint_price'] as num : null,
    );
  }

  static String? _extractName(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic> && value['name'] is String) return value['name'] as String;
    return null;
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<AppointmentListItemModel> listFromJson(dynamic json) {
    final rawList = JsonListExtractor.extractList(json);
    final result = <AppointmentListItemModel>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(AppointmentListItemModel.fromJson(item));
        } catch (e) {
          debugPrint('[APPOINTMENTS] Skipped one malformed item ($e). Raw item: $item');
        }
      }
    }
    return result;
  }
}