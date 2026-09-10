import 'package:flutter/foundation.dart';
import '../../core/utils/json_list_extractor.dart';

class SpecializationModel {
  final int id;
  final String name;

  const SpecializationModel({required this.id, required this.name});

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    return SpecializationModel(
      id: _parseId(json['id']),
      name: (json['name'] ?? json['title'] ?? 'Specialization') as String,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<SpecializationModel> listFromJson(dynamic json) {
    final rawList = JsonListExtractor.extractList(json);
    final result = <SpecializationModel>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(SpecializationModel.fromJson(item));
        } catch (e) {
          debugPrint('[SPECIALIZATIONS] Skipped one malformed item ($e). Raw item: $item');
        }
      }
    }
    return result;
  }
}