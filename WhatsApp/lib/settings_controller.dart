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
    final settings = jsonDecode(contents) as Map<String, dynamic>;
    debugPrint(contents[0]);
    // if (contents['theme'] == "")
    // _themeMode = ;
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(newThemeMode) async {
    final file = await _settingsFile;
    file.writeAsString(json.encode([
      {"theme": newThemeMode.toString()}
    ]));
    _themeMode = newThemeMode;
    notifyListeners();
  }
}
