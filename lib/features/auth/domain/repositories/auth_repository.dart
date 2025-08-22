import 'package:webak/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? username,
    Map<String, dynamic>? metadata,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current user
  Future<UserModel?> getCurrentUser();

  /// Reset password
  Future<void> resetPassword(String email);

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  });

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get auth state changes stream
  Stream<UserModel?> get authStateChanges;
}