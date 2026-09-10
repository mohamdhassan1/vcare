class UserProfileModel {
  final String name;
  final String? email;
  final String? phone;
  final String? imageUrl;

  const UserProfileModel(
      {required this.name, this.email, this.phone, this.imageUrl});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    var data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    // Some APIs nest the profile one level deeper, e.g. data.user.*
    if (data['user'] is Map<String, dynamic>) {
      data = data['user'] as Map<String, dynamic>;
    }
    final name = data['name'] ??
        data['username'] ??
        data['full_name'] ??
        data['user_name'];
    return UserProfileModel(
      name: (name is String && name.isNotEmpty) ? name : 'User',
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      imageUrl: (data['image'] ?? data['avatar'] ?? data['photo']) as String?,
    );
  }
}
