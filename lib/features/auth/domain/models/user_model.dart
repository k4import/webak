class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? lastSignInAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.lastSignInAt,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      lastSignInAt: json['last_sign_in_at'] != null ? DateTime.parse(json['last_sign_in_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      role: json['role'] ?? json['metadata']?['role'],
      metadata: json['metadata'],
    );
  }


}