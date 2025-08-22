import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webak/core/database/database_helper.dart';
import 'package:webak/features/auth/domain/models/user_model.dart';

class DatabaseConfig {
  // Singleton instance
  static final DatabaseConfig _instance = DatabaseConfig._internal();
  static DatabaseConfig get instance => _instance;
  
  // Private constructor
  DatabaseConfig._internal() {
    _databaseHelper = DatabaseHelper();
    _authStateController = StreamController<UserModel?>.broadcast();
  }

  // Database helper instance
  late final DatabaseHelper _databaseHelper;
  UserModel? _currentUser;
  late final StreamController<UserModel?> _authStateController;

  // Getter for database helper
  DatabaseHelper get databaseHelper => _databaseHelper;

  // Initialize Database
  Future<void> initialize() async {
    try {
      await _databaseHelper.database;
      // Database initialized successfully
    } catch (e) {
      // Error initializing local database
      rethrow;
    }
  }

  // Check if database is initialized
  bool get isInitialized => _databaseHelper.isInitialized;

  // Set current user
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Get current user ID
  String? get currentUserId => _currentUser?.id;

  // Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Stream for auth state changes
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
}