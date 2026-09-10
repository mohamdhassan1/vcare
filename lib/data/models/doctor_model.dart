import 'package:flutter/foundation.dart';
import '../../core/utils/json_list_extractor.dart';

class DoctorModel {
  final int id;
  final String name;
  final String? specialization;
  final String? hospital;
  final double? rating;
  final int? reviewsCount;
  final String? imageUrl;
  final String? description;
  final String? degree;
  final num? appointPrice;
  final String? startTime;
  final String? endTime;

  const DoctorModel({
    required this.id,
    required this.name,
    this.specialization,
    this.hospital,
    this.rating,
    this.reviewsCount,
    this.imageUrl,
    this.description,
    this.degree,
    this.appointPrice,
    this.startTime,
    this.endTime,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: _parseId(json['id']),
      name: (json['name'] ?? json['full_name'] ?? 'Doctor') as String,
      specialization: _extractName(json['specialization'] ?? json['specialty'] ?? json['category']),
      hospital: _extractName(json['city']) ?? (json['hospital'] ?? json['location'] ?? json['address']) as String?,
      rating: (json['rating'] ?? json['avg_rating']) != null
          ? double.tryParse('${json['rating'] ?? json['avg_rating']}')
          : null,
      reviewsCount: (json['reviews_count'] ?? json['reviews']) != null
          ? int.tryParse('${json['reviews_count'] ?? json['reviews']}')
          : null,
      imageUrl: (json['image'] ?? json['photo'] ?? json['avatar']) as String?,
      description: json['description'] as String?,
      degree: json['degree'] as String?,
      appointPrice: json['appoint_price'] is num ? json['appoint_price'] as num : num.tryParse('${json['appoint_price']}'),
      startTime: _cleanTime(json['start_time']),
      endTime: _cleanTime(json['end_time']),
    );
  }

  static String? _cleanTime(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return value.length >= 5 ? value.substring(0, 5) : value;
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

  static List<DoctorModel> listFromJson(dynamic json) {
    final rawList = JsonListExtractor.extractList(json);
    final result = <DoctorModel>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(DoctorModel.fromJson(item));
        } catch (e) {
          debugPrint('[DOCTORS] Skipped one malformed doctor item ($e). Raw item: $item');
        }
      }
    }
    return result;
  }
}