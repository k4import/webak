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

  // Helper factory to create a user from Supabase auth response
  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'] ?? '',
      username: map['username'] ?? map['user_name'],
      fullName: map['full_name'] ?? map['user_metadata']?['full_name'],
      avatarUrl: map['avatar_url'] ?? map['user_metadata']?['avatar_url'],
      lastSignInAt: map['last_sign_in_at'] != null
          ? DateTime.parse(map['last_sign_in_at'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      role: map['role'] ?? map['user_metadata']?['role'],
      metadata: map['user_metadata'] ?? map['metadata'],
    );
  }

  // Helper method to convert to Supabase format
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'email': email,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastSignInAt != null) 'last_sign_in_at': lastSignInAt!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (role != null) 'role': role,
      if (metadata != null) 'user_metadata': metadata,
    };
  }
}