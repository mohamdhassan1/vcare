class UserProfileModel {
  /// Empty when the API did not provide a name. Callers that need a
  /// display value should go through UserRepository, which applies the
  /// stored login username / generic fallback — never this model.
  final String name;
  final String? email;
  final String? phone;

  /// Raw gender value exactly as the API returned it (e.g. "0"/"1" or
  /// "male"/"female" — the backend's representation is unverified, so
  /// nothing is normalised here). Null when absent.
  final String? gender;
  final String? imageUrl;

  const UserProfileModel({
    required this.name,
    this.email,
    this.phone,
    this.gender,
    this.imageUrl,
  });

  bool get hasName => name.trim().isNotEmpty;

  UserProfileModel copyWith({String? name}) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email,
      phone: phone,
      gender: gender,
      imageUrl: imageUrl,
    );
  }

  /// Accepts the raw decoded response body. Handles every envelope the
  /// VCare API is known to use:
  ///   { "data": { ...profile } }
  ///   { "data": [ { ...profile } ] }   ← observed for /user/profile
  ///   { "data": { "user": { ...profile } } }
  ///   { ...profile }
  /// Malformed/empty payloads produce a model with an empty name rather
  /// than throwing, so the UI can still render and fall back honestly.
  factory UserProfileModel.fromJson(dynamic json) {
    final data = _unwrap(json);
    final name = _string(data['name']) ??
        _string(data['username']) ??
        _string(data['full_name']) ??
        _string(data['user_name']);
    return UserProfileModel(
      name: name ?? '',
      email: _string(data['email']),
      phone: _string(data['phone']),
      gender: _string(data['gender']),
      imageUrl: _string(data['image']) ??
          _string(data['avatar']) ??
          _string(data['photo']),
    );
  }

  static Map<String, dynamic> _unwrap(dynamic json) {
    // A bare list at the top level: take the first profile object.
    if (json is List) return _firstMap(json);
    if (json is! Map<String, dynamic>) return const {};

    var data = json['data'];
    if (data is List) data = _firstMap(data);
    var map = data is Map<String, dynamic> ? data : json;

    // Some APIs nest the profile one level deeper, e.g. data.user.*
    if (map['user'] is Map<String, dynamic>) {
      map = map['user'] as Map<String, dynamic>;
    }
    return map;
  }

  static Map<String, dynamic> _firstMap(List list) {
    for (final item in list) {
      if (item is Map<String, dynamic>) return item;
    }
    return const {};
  }

  /// Tolerant string read: ints (e.g. gender 0/1, numeric phone) are
  /// stringified instead of crashing on an `as String?` cast; blank
  /// strings count as absent.
  static String? _string(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value;
    if (value is num || value is bool) return value.toString();
    return null;
  }
}
