class CityModel {
  final int id;
  final String name;

  const CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? json['title'] ?? 'City') as String,
    );
  }

  static List<CityModel> listFromJson(dynamic json) {
    final list = (json is Map<String, dynamic> && json['data'] is List)
        ? json['data'] as List
        : (json is List ? json : []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(CityModel.fromJson)
        .toList();
  }
}
