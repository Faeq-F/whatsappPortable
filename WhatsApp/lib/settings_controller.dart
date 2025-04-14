import 'package:flutter/material.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
///The SettingsController uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  final SettingsService _settingsService;
  SettingsController(this._settingsService);

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _themeMode = _settingsService.themeMode;
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(newThemeMode) async {
    _themeMode = newThemeMode;
    notifyListeners();
    _settingsService.themeMode = _themeMode;
  }
}
