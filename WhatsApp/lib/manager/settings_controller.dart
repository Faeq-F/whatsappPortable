import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class SettingsController with ChangeNotifier {
  SettingsController();

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  bool _alwaysShowTabBar = true;
  bool get alwaysShowTabBar => _alwaysShowTabBar;

  Future<File> get _settingsFile async {
    final path = Directory.current.path;
    return File('$path/settings.json');
  }

  Future<Map<String, dynamic>> readSettings() async {
    final file = await _settingsFile;
    if (!await file.exists()) return {};
    final contents = await file.readAsString();
    if (contents.isEmpty) return {};
    try {
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> writeSettings(Map<String, dynamic> settings) async {
    final file = await _settingsFile;
    await file.writeAsString(jsonEncode(settings));
  }

  Future<void> loadSettings() async {
    final settings = await readSettings();
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

    _alwaysShowTabBar = settings['alwaysShowTabBar'] ?? true;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    final settings = await readSettings();
    settings['theme'] = newThemeMode.toString();
    await writeSettings(settings);
    _themeMode = newThemeMode;
    notifyListeners();
  }

  Future<void> updateAlwaysShowTabBar(bool value) async {
    final settings = await readSettings();
    settings['alwaysShowTabBar'] = value;
    await writeSettings(settings);
    _alwaysShowTabBar = value;
    notifyListeners();
  }
}
