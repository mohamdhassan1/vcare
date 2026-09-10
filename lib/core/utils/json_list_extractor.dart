/// Shared JSON list-unwrapping helper. Previously duplicated
/// identically in DoctorModel, SpecializationModel, and
/// AppointmentListItemModel — extracted once here.
class JsonListExtractor {
  JsonListExtractor._();

  static List extractList(dynamic json) {
    if (json is List) return json;
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['data'] is List) return data['data'] as List;
    }
    return [];
  }
}