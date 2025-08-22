class User {
  final String? id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? role;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  User({
    this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.role,
    this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'user',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Helper factory to create a user from Supabase response
  factory User.fromSupabase(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'] ?? '',
      fullName: map['full_name'],
      phoneNumber: map['phone_number'],
      avatarUrl: map['avatar_url'],
      role: map['role'] ?? 'user',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'])
          : null,
      metadata: map['metadata'],
    );
  }
}