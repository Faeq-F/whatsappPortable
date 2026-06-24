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

  bool _translateMessageButton = true;
  bool get translateMessageButton => _translateMessageButton;

  bool _keepAppInEnglish = false;
  bool get keepAppInEnglish => _keepAppInEnglish;

  bool _fullPageTranslation = false;
  bool get fullPageTranslation => _fullPageTranslation;

  bool _showTranslateAllMessagesButton = true;
  bool get showTranslateAllMessagesButton => _showTranslateAllMessagesButton;

  String _language = 'en';
  String get language => _language;

  AppLocalizations _localizations =
      AppLocalizations(AppLocalizations.enStrings);
  AppLocalizations get localizations => _localizations;

  List<Map<String, String>> _supportedLanguages = [
    {"name": "English", "code": "en"},
  ];
  List<Map<String, String>> get supportedLanguages => _supportedLanguages;

  bool _isTranslating = false;
  bool get isTranslating => _isTranslating;

  Map<String, Map<String, String>> _cachedTranslations = {};

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
    await file.writeAsString(const JsonEncoder.withIndent('    ').convert(settings));
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
    _translateMessageButton = settings['translateMessageButton'] ?? settings['enableHoverTranslation'] ?? true;
    _keepAppInEnglish = settings['keepAppInEnglish'] ?? settings['translateContentOnly'] ?? false;
    _fullPageTranslation = settings['fullPageTranslation'] ?? settings['enableFullPageTranslation'] ?? false;
    _showTranslateAllMessagesButton = settings['showTranslateAllMessagesButton'] ?? true;
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

    _cachedTranslations = {};
    if (cacheData != null) {
      final cachedLangs = cacheData['supported_languages'] as List<dynamic>?;
      if (cachedLangs != null) {
        _supportedLanguages = cachedLangs
            .map((item) => Map<String, String>.from(item as Map))
            .toList();
      }

      // Handle migration of legacy caching structures
      final Map<String, dynamic> tempCachedMap = {};
      if (cacheData['cached_translations'] != null) {
        tempCachedMap.addAll(cacheData['cached_translations'] as Map<String, dynamic>);
      } else if (cacheData['cached_language'] != null && cacheData['translations'] != null) {
        tempCachedMap[cacheData['cached_language'] as String] = cacheData['translations'];
      }

      tempCachedMap.forEach((langCode, val) {
        if (val is Map) {
          _cachedTranslations[langCode] = val.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      });
    }

    _fallbackOrLoadTranslations();

    _loadSupportedLanguagesAsync();

    notifyListeners();
  }

  Future<void> _loadSupportedLanguagesAsync() async {
    try {
      final langs = await AppLanguages.fetchSupportedLanguages();
      if (langs.isNotEmpty) {
        _supportedLanguages = langs;

        final cacheFile = await _cacheFile;
        Map<String, dynamic> cacheData = {};
        if (await cacheFile.exists()) {
          try {
            final contents = await cacheFile.readAsString();
            if (contents.isNotEmpty) {
              cacheData = jsonDecode(contents) as Map<String, dynamic>;
            }
          } catch (_) {}
        }
        cacheData['supported_languages'] = langs;
        cacheData['cached_translations'] = _cachedTranslations;
        cacheData.remove('cached_language');
        cacheData.remove('translations');
        await cacheFile.writeAsString(const JsonEncoder.withIndent('    ').convert(cacheData));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load supported languages async: $e');
    }
  }

  void _fallbackOrLoadTranslations() {
    if (_language == 'en' || _keepAppInEnglish) {
      _localizations = AppLocalizations(AppLocalizations.enStrings);
    } else if (_cachedTranslations.containsKey(_language)) {
      final cached = _cachedTranslations[_language]!;
      final hasAllKeys = AppLocalizations.enStrings.keys.every((key) => cached.containsKey(key));
      if (hasAllKeys) {
        _localizations = AppLocalizations(cached);
      } else {
        _loadTranslationsAsync(_language);
      }
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
      _cachedTranslations[langCode] = fetched;

      final cacheFile = await _cacheFile;
      Map<String, dynamic> cacheData = {};
      if (await cacheFile.exists()) {
        try {
          final contents = await cacheFile.readAsString();
          if (contents.isNotEmpty) {
            cacheData = jsonDecode(contents) as Map<String, dynamic>;
          }
        } catch (_) {}
      }
      cacheData['cached_translations'] = _cachedTranslations;
      cacheData.remove('cached_language');
      cacheData.remove('translations');
      await cacheFile.writeAsString(const JsonEncoder.withIndent('    ').convert(cacheData));
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

    if (newLanguage == 'en' || _keepAppInEnglish) {
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

  Future<void> updateTranslateMessageButton(bool value) async {
    final settings = await readSettings();
    settings['translateMessageButton'] = value;
    await writeSettings(settings);
    _translateMessageButton = value;
    notifyListeners();
  }

  Future<void> updateKeepAppInEnglish(bool value) async {
    final settings = await readSettings();
    settings['keepAppInEnglish'] = value;
    await writeSettings(settings);
    _keepAppInEnglish = value;
    
    if (value) {
      _localizations = AppLocalizations(AppLocalizations.enStrings);
    } else {
      if (_language == 'en') {
        _localizations = AppLocalizations(AppLocalizations.enStrings);
      } else {
        await _loadTranslationsAsync(_language);
      }
    }
    notifyListeners();
  }

  Future<void> updateFullPageTranslation(bool value) async {
    final settings = await readSettings();
    settings['fullPageTranslation'] = value;
    await writeSettings(settings);
    _fullPageTranslation = value;
    notifyListeners();
  }

  Future<void> updateShowTranslateAllMessagesButton(bool value) async {
    final settings = await readSettings();
    settings['showTranslateAllMessagesButton'] = value;
    await writeSettings(settings);
    _showTranslateAllMessagesButton = value;
    notifyListeners();
  }
}
