import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
///The SettingsController uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController();

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  Future<File> get _settingsFile async {
    //handle obtain file error  - create file with default
    final path = Directory.current.path;
    return File('$path/settings.json');
  }

  Future<void> loadSettings() async {
    final file = await _settingsFile;
    final contents = await file.readAsString();

    //handle decode error - overwrite file
    if (contents.isEmpty) {
      _themeMode = ThemeMode.system;
    } else {
      final settings = jsonDecode(contents) as Map<String, dynamic>;
      final themeString = settings['theme'] as String? ?? 'ThemeMode.system';

      switch (themeString) {
        case 'ThemeMode.light':
          _themeMode = ThemeMode.light;
          break;
        case 'ThemeMode.dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    }
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(newThemeMode) async {
    final file = await _settingsFile;
    file.writeAsString(json.encode({"theme": newThemeMode.toString()}));
    _themeMode = newThemeMode;
    notifyListeners();
  }
}
