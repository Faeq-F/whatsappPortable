import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeMode = 'theme_mode';

/// A service that stores and retrieves user settings.
///
class SettingsService {
  /// Persist and retrieve theme mode
  ThemeMode get themeMode => _getData(_kThemeMode) ?? ThemeMode.system;
  set themeMode(ThemeMode value) => _saveData(_kThemeMode, value);

  static SettingsService? _instance;
  static late SharedPreferences _preferences;

  SettingsService._();

  // Using a singleton pattern
  static Future<SettingsService> getInstance() async {
    _instance ??= SettingsService._();

    _preferences = await SharedPreferences.getInstance();

    return _instance!;
  }

  // Private generic method for retrieving data from shared preferences
  dynamic _getData(String key) {
    var value = _preferences.get(key);
    debugPrint('Retrieved $key: $value');
    return value;
  }

  // Private method for saving data to shared preferences
  void _saveData(String key, dynamic value) {
    debugPrint('Saving $key: $value');
    if (value is String) {
      _preferences.setString(key, value);
    } else if (value is int) {
      _preferences.setInt(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is List<String>) {
      _preferences.setStringList(key, value);
    }
  }
}
