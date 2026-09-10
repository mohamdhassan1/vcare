class GovernorateModel {
  final int id;
  final String name;

  const GovernorateModel({required this.id, required this.name});

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? json['title'] ?? 'Governorate') as String,
    );
  }

  static List<GovernorateModel> listFromJson(dynamic json) {
    final list = (json is Map<String, dynamic> && json['data'] is List)
        ? json['data'] as List
        : (json is List ? json : []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(GovernorateModel.fromJson)
        .toList();
  }
}
