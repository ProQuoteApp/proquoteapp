import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to manage theme settings
class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _initialized = false;
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Whether the current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Whether the provider has been initialized
  bool get initialized => _initialized;
  
  /// Constructor
  ThemeProvider() {
    _loadThemePreference();
  }
  
  /// Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);
      
      if (savedTheme != null) {
        _themeMode = _getThemeModeFromString(savedTheme);
      }
      
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _initialized = true;
      notifyListeners();
    }
  }
  
  /// Save theme preference to shared preferences
  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
  
  /// Convert string to ThemeMode
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    await _saveThemePreference(mode);
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// Use system theme
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
} 