import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'localization.dart';

class SettingsController with ChangeNotifier {
  SettingsController();

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  bool _alwaysShowTabBar = true;
  bool get alwaysShowTabBar => _alwaysShowTabBar;

  bool _checkForUpdates = true;
  bool get checkForUpdates => _checkForUpdates;

  String _language = 'en';
  String get language => _language;

  AppLocalizations _localizations =
      AppLocalizations(AppLocalizations.enStrings);
  AppLocalizations get localizations => _localizations;

  bool _isTranslating = false;
  bool get isTranslating => _isTranslating;

  Future<File> get _settingsFile async {
    final path = Directory.current.path;
    return File('$path/settings.json');
  }

  Future<File> get _cacheFile async {
    final path = Directory.current.path;
    return File('$path/translations_cache.json');
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
    _checkForUpdates = settings['checkForUpdates'] ?? true;
    _language = settings['language'] ?? 'en';

    final cacheFile = await _cacheFile;
    Map<String, dynamic>? cacheData;
    if (await cacheFile.exists()) {
      try {
        final cacheContent = await cacheFile.readAsString();
        if (cacheContent.isNotEmpty) {
          cacheData = jsonDecode(cacheContent) as Map<String, dynamic>?;
        }
      } catch (e) {
        debugPrint('Failed to read translations cache: $e');
      }
    }

    if (cacheData != null && cacheData['cached_language'] == _language) {
      final cached = cacheData['translations'] as Map<String, dynamic>?;
      if (cached != null) {
        _localizations =
            AppLocalizations(cached.map((k, v) => MapEntry(k, v.toString())));
      } else {
        _fallbackOrLoadTranslations();
      }
    } else {
      _fallbackOrLoadTranslations();
    }

    notifyListeners();
  }

  void _fallbackOrLoadTranslations() {
    if (_language == 'en') {
      _localizations = AppLocalizations(AppLocalizations.enStrings);
    } else {
      _loadTranslationsAsync(_language);
    }
  }

  Future<void> _loadTranslationsAsync(String langCode) async {
    _isTranslating = true;
    notifyListeners();
    try {
      final fetched = await AppLocalizations.fetchTranslations(langCode);
      _localizations = AppLocalizations(fetched);

      final cacheFile = await _cacheFile;
      await cacheFile.writeAsString(jsonEncode({
        'cached_language': langCode,
        'translations': fetched,
      }));
    } catch (e) {
      debugPrint('Failed to load translations async: $e');
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  Future<void> updateLanguage(String newLanguage) async {
    if (_language == newLanguage) return;

    _language = newLanguage;
    final settings = await readSettings();
    settings['language'] = newLanguage;
    await writeSettings(settings);

    if (newLanguage == 'en') {
      _localizations = AppLocalizations(AppLocalizations.enStrings);
      notifyListeners();
    } else {
      await _loadTranslationsAsync(newLanguage);
    }
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

  Future<void> updateCheckForUpdates(bool value) async {
    final settings = await readSettings();
    settings['checkForUpdates'] = value;
    await writeSettings(settings);
    _checkForUpdates = value;
    notifyListeners();
  }
}
