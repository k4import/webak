import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _prefs;
  
  // Keys for different cached data
  static const String _userKey = 'cached_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _loginTimeKey = 'login_time';
  
  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Ensure SharedPreferences is initialized
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('CacheHelper not initialized. Call CacheHelper.init() first.');
    }
    return _prefs!;
  }
  
  // Save user login data
  static Future<bool> saveUserLogin({
    required String userId,
    required String email,
    required String role,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final loginTime = DateTime.now().toIso8601String();
      
      await Future.wait([
        prefs.setBool(_isLoggedInKey, true),
        prefs.setString(_userIdKey, userId),
        prefs.setString(_userEmailKey, email),
        prefs.setString(_userRoleKey, role),
        prefs.setString(_loginTimeKey, loginTime),
        if (userData != null) prefs.setString(_userKey, json.encode(userData)),
      ]);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Check if user is logged in
  static bool isLoggedIn() {
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  // Get cached user ID
  static String? getUserId() {
    return prefs.getString(_userIdKey);
  }
  
  // Get cached user email
  static String? getUserEmail() {
    return prefs.getString(_userEmailKey);
  }
  
  // Get cached user role
  static String? getUserRole() {
    return prefs.getString(_userRoleKey);
  }
  
  // Get cached user data
  static Map<String, dynamic>? getUserData() {
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      try {
        return json.decode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Get login time
  static DateTime? getLoginTime() {
    final loginTimeString = prefs.getString(_loginTimeKey);
    if (loginTimeString != null) {
      try {
        return DateTime.parse(loginTimeString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Check if login session is still valid (optional expiry check)
  static bool isSessionValid({Duration? maxAge}) {
    if (!isLoggedIn()) return false;
    
    if (maxAge != null) {
      final loginTime = getLoginTime();
      if (loginTime != null) {
        final now = DateTime.now();
        final sessionAge = now.difference(loginTime);
        return sessionAge <= maxAge;
      }
    }
    
    return true;
  }
  
  // Clear user login data (logout)
  static Future<bool> clearUserLogin() async {
    try {
      await Future.wait([
        prefs.remove(_isLoggedInKey),
        prefs.remove(_userIdKey),
        prefs.remove(_userEmailKey),
        prefs.remove(_userRoleKey),
        prefs.remove(_userKey),
        prefs.remove(_loginTimeKey),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Update user data
  static Future<bool> updateUserData(Map<String, dynamic> userData) async {
    try {
      await prefs.setString(_userKey, json.encode(userData));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Generic methods for other cache needs
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }
  
  static String? getString(String key) {
    return prefs.getString(key);
  }
  
  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }
  
  static bool? getBool(String key) {
    return prefs.getBool(key);
  }
  
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }
  
  static int? getInt(String key) {
    return prefs.getInt(key);
  }
  
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }
  
  static Future<bool> clear() async {
    return await prefs.clear();
  }
  
  // Check if a key exists
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }
  
  // Get all keys
  static Set<String> getKeys() {
    return prefs.getKeys();
  }
}