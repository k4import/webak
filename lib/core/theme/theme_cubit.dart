import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webak/core/theme/app_theme.dart';

/// --- Theme States ---
abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;
  final ThemeData theme;

  ThemeLoaded({required this.themeMode, required this.theme});
}

/// --- Theme Cubit ---
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themePreferenceKey = 'theme_mode';

  ThemeMode _currentThemeMode = ThemeMode.light;

  ThemeCubit() : super(ThemeInitial()) {
    loadTheme();
  }

  /// Load saved theme from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey) ?? 'light';

    if (savedTheme == 'dark') {
      _currentThemeMode = ThemeMode.dark;
      emit(ThemeLoaded(themeMode: ThemeMode.dark, theme: AppTheme.darkTheme));
    } else {
      _currentThemeMode = ThemeMode.light;
      emit(ThemeLoaded(themeMode: ThemeMode.light, theme: AppTheme.lightTheme));
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_currentThemeMode == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }

  /// Set a specific theme and save it
  Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();

    _currentThemeMode = themeMode;
    await prefs.setString(_themePreferenceKey, themeMode == ThemeMode.dark ? 'dark' : 'light');

    emit(ThemeLoaded(
      themeMode: _currentThemeMode,
      theme: _currentThemeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
    ));
  }

  /// Get current theme mode
  ThemeMode get themeMode => _currentThemeMode;

  /// Check if dark mode is active
  bool get isDarkMode => _currentThemeMode == ThemeMode.dark;
}
