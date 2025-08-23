import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:webak/core/config/database_config.dart';
import 'package:webak/features/auth/domain/models/user_model.dart';
import 'package:webak/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositorySQLiteImpl implements AuthRepository {
  final _uuid = const Uuid();
  final String _tableName = 'users';
  final DatabaseConfig _databaseConfig = DatabaseConfig.instance;

  AuthRepositorySQLiteImpl();

  // No need to initialize table as it's already done in DatabaseHelper

  // Get database instance
  Future<Database> get _database => _databaseConfig.databaseHelper.database;

  UserModel _userFromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'] ?? '',
      username: map['username'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      lastSignInAt: map['last_sign_in_at'] != null ? DateTime.parse(map['last_sign_in_at']) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      role: map['role'],
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    );
  }

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final db = await _database;
    final result = await db.query(
      _tableName,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

      if (result.isEmpty) {
        throw Exception('Invalid email or password');
      }

      final user = _userFromMap(result.first);
      
      // Update last sign in time
      await db.update(
        _tableName,
        {'last_sign_in_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [user.id],
      );

      // Update current user in DatabaseConfig
      _databaseConfig.setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? username,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if user already exists
      final db = await _database;
      final existingUser = await db.query(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUser.isNotEmpty) {
        throw Exception('User with this email already exists');
      }

      final userId = _uuid.v4();
      final now = DateTime.now();

      // Default role is 'employee'
      final role = metadata?['role'] ?? 'employee';

      await db.insert(_tableName, {
        'id': userId,
        'email': email,
        'password': password, // In a real app, this would be hashed
        'username': username,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'role': role,
        'metadata': metadata != null ? jsonEncode(metadata) : null,
      });

      final user = UserModel(
        id: userId,
        email: email,
        username: username,
        role: role,
        createdAt: now,
        updatedAt: now,
        metadata: metadata,
      );

      // Update current user in DatabaseConfig
      _databaseConfig.setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    _databaseConfig.setCurrentUser(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Check if we have a current user in DatabaseConfig
    final currentUser = _databaseConfig.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    // No automatic login - user must explicitly sign in
    return null;
  }

  @override
  Future<void> resetPassword(String email) async {
    // In a real app, this would send a reset email
    // For this demo, we'll just reset the password to a default value
    try {
      final db = await _database;
      final result = await db.query(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isEmpty) {
        throw Exception('User not found');
      }

      await db.update(
        _tableName,
        {'password': 'resetpassword123'},
        where: 'email = ?',
        whereArgs: [email],
      );
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (metadata != null) updates['metadata'] = jsonEncode(metadata);
      updates['updated_at'] = DateTime.now().toIso8601String();

      final db = await _database;
      await db.update(
        _tableName,
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );

      final result = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) {
        throw Exception('User not found');
      }

      final updatedUser = _userFromMap(result.first);
      if (_databaseConfig.currentUser?.id == userId) {
        _databaseConfig.setCurrentUser(updatedUser);
      }

      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _databaseConfig.isAuthenticated;
  }

  @override
  Stream<UserModel?> get authStateChanges => _databaseConfig.authStateChanges;
}