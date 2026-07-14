import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

const String _googleTranslateBaseUrl = 'https://translate.googleapis.com';

class AppLanguages {
  static bool isRtl(String code) {
    const rtlCodes = {
      'ar',
      'fa',
      'he',
      'iw',
      'ur',
      'yi',
      'ps',
      'sd',
      'ug',
      'syc'
    };
    final baseCode = code.split('-').first.toLowerCase();
    return rtlCodes.contains(baseCode);
  }

  static Future<List<Map<String, String>>> fetchSupportedLanguages() async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(
          '$_googleTranslateBaseUrl/translate_a/l?client=gtx&hl=en');
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(content) as Map<String, dynamic>;
        final tl = decoded['tl'] as Map<String, dynamic>?;
        if (tl != null) {
          final List<Map<String, String>> langs = [];
          tl.forEach((code, name) {
            langs.add({'name': name.toString(), 'code': code.toString()});
          });
          langs.sort((a, b) => a['name']!.compareTo(b['name']!));
          return langs;
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch supported languages: $e');
    } finally {
      client.close();
    }
    return [];
  }
}

class AppLocalizations {
  final Map<String, String> _translations;

  AppLocalizations(this._translations);

  static const Map<String, String> enStrings = {
    'settings': 'Settings',
    'general': 'General',
    'theme': 'Theme',
    'system': 'System',
    'light': 'Light',
    'dark': 'Dark',
    'match_cohesive': 'Match this setting in WhatsApp for a cohesive look.',
    'manage_accounts': 'Manage Accounts',
    'add_account': 'Add account',
    'always_show_tab_bar': 'Always show tab bar',
    'minimize_window_on_startup': 'Minimize window on startup',
    'updates': 'Updates',
    'check_updates_launch': 'Check for updates on launch',
    'check_now': 'Check Now',
    'devtools': 'DevTools',
    'debug_active_tab': 'Debug active tab',
    'delete_account_title': 'Delete Account',
    'delete_account_confirm':
        'Delete "{name}"? This will remove all data for this account.',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'rename': 'Rename',
    'language': 'Language',
    'translate_to_lang': 'Translate to {lang}',
    'translate_all_messages': 'Translate all messages',
    'toggle_window': 'Toggle Window',
    'exit': 'Exit',
    'translate_message_button': 'Translate message button ',
    'keep_app_in_english': 'Keep app UI in English',
    'full_page_translation': 'Translate entire page',
    'show_translate_all_messages_button':
        'Title bar translate all messages button',
    'reload_active_tab': 'Reload active tab',
    'notifications': 'Notifications',
    'translate_notifications': 'Translate notification messages',
    'show_translate_notification_button':
        'Show translate button in notifications',
    'notification_button_info':
        'Will cause the notification auto-dismiss period to be longer.',
  };

  String get(String key, {Map<String, String>? args}) {
    String value = _translations[key] ?? enStrings[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }

  static Future<Map<String, String>> fetchTranslations(
      String targetLang) async {
    if (targetLang == 'en') {
      return enStrings;
    }

    final Map<String, String> translated = {};
    final client = HttpClient();

    for (final entry in enStrings.entries) {
      if (entry.key == 'delete_account_confirm') {
        final textToTranslate = entry.value.replaceAll('{name}', '___');
        final translatedText =
            await _translateText(client, textToTranslate, targetLang);
        translated[entry.key] = translatedText.replaceAll('___', '{name}');
      } else if (entry.key == 'translate_to_lang') {
        final translatedPrefix =
            await _translateText(client, "Translate to", targetLang);
        translated[entry.key] = "$translatedPrefix {lang}";
      } else {
        translated[entry.key] =
            await _translateText(client, entry.value, targetLang);
      }
    }
    client.close();
    return translated;
  }

  static Future<String> translateSingle(String text, String targetLang) async {
    final client = HttpClient();
    try {
      final res = await _translateText(client, text, targetLang);
      client.close();
      return res;
    } catch (e) {
      client.close();
      rethrow;
    }
  }

  static Future<String> _translateText(
      HttpClient client, String text, String targetLang) async {
    try {
      final uri = Uri.parse(
          '$_googleTranslateBaseUrl/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}');
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(content);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final parts = decoded[0] as List;
          return parts.map((part) => part[0] as String).join();
        }
      }
    } catch (e) {
      debugPrint('Translation error for "$text": $e');
    }
    return text;
  }
}
