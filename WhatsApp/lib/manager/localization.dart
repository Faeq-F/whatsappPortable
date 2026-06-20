import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class AppLanguages {
  static const List<Map<String, String>> list = [
    {"name": "Afrikaans", "code": "af"},
    {"name": "Albanian", "code": "sq"},
    {"name": "Amharic", "code": "am"},
    {"name": "Arabic", "code": "ar"},
    {"name": "Armenian", "code": "hy"},
    {"name": "Azerbaijani", "code": "az"},
    {"name": "Basque", "code": "eu"},
    {"name": "Bengali", "code": "bn"},
    {"name": "Bosnian", "code": "bs"},
    {"name": "Bulgarian", "code": "bg"},
    {"name": "Catalan", "code": "ca"},
    {"name": "Chinese (Simplified)", "code": "zh-CN"},
    {"name": "Chinese (Traditional)", "code": "zh-TW"},
    {"name": "Croatian", "code": "hr"},
    {"name": "Czech", "code": "cs"},
    {"name": "Danish", "code": "da"},
    {"name": "Dutch", "code": "nl"},
    {"name": "English", "code": "en"},
    {"name": "Esperanto", "code": "eo"},
    {"name": "Estonian", "code": "et"},
    {"name": "Finnish", "code": "fi"},
    {"name": "French", "code": "fr"},
    {"name": "Galician", "code": "gl"},
    {"name": "Georgian", "code": "ka"},
    {"name": "German", "code": "de"},
    {"name": "Greek", "code": "el"},
    {"name": "Gujarati", "code": "gu"},
    {"name": "Haitian Creole", "code": "ht"},
    {"name": "Hebrew", "code": "he"},
    {"name": "Hindi", "code": "hi"},
    {"name": "Hungarian", "code": "hu"},
    {"name": "Icelandic", "code": "is"},
    {"name": "Indonesian", "code": "id"},
    {"name": "Irish", "code": "ga"},
    {"name": "Italian", "code": "it"},
    {"name": "Japanese", "code": "ja"},
    {"name": "Kannada", "code": "kn"},
    {"name": "Kazakh", "code": "kk"},
    {"name": "Korean", "code": "ko"},
    {"name": "Latvian", "code": "lv"},
    {"name": "Lithuanian", "code": "lt"},
    {"name": "Macedonian", "code": "mk"},
    {"name": "Malay", "code": "ms"},
    {"name": "Malayalam", "code": "ml"},
    {"name": "Marathi", "code": "mr"},
    {"name": "Mongolian", "code": "mn"},
    {"name": "Nepali", "code": "ne"},
    {"name": "Norwegian", "code": "no"},
    {"name": "Persian", "code": "fa"},
    {"name": "Polish", "code": "pl"},
    {"name": "Portuguese", "code": "pt"},
    {"name": "Punjabi", "code": "pa"},
    {"name": "Romanian", "code": "ro"},
    {"name": "Russian", "code": "ru"},
    {"name": "Serbian", "code": "sr"},
    {"name": "Slovak", "code": "sk"},
    {"name": "Slovenian", "code": "sl"},
    {"name": "Spanish", "code": "es"},
    {"name": "Swahili", "code": "sw"},
    {"name": "Swedish", "code": "sv"},
    {"name": "Tamil", "code": "ta"},
    {"name": "Telugu", "code": "te"},
    {"name": "Thai", "code": "th"},
    {"name": "Turkish", "code": "tr"},
    {"name": "Ukrainian", "code": "uk"},
    {"name": "Urdu", "code": "ur"},
    {"name": "Uzbek", "code": "uz"},
    {"name": "Vietnamese", "code": "vi"},
    {"name": "Welsh", "code": "cy"},
    {"name": "Yiddish", "code": "yi"},
    {"name": "Zulu", "code": "zu"}
  ];

  static bool isRtl(String code) {
    const rtlCodes = {'ar', 'fa', 'he', 'iw', 'ur', 'yi', 'ps', 'sd', 'ug', 'syc'};
    final baseCode = code.split('-').first.toLowerCase();
    return rtlCodes.contains(baseCode);
  }
}

class AppLocalizations {
  final Map<String, String> _translations;

  AppLocalizations(this._translations);

  static const Map<String, String> enStrings = {
    'settings': 'Settings',
    'theme': 'Theme',
    'system': 'System',
    'light': 'Light',
    'dark': 'Dark',
    'match_cohesive': 'Match this setting in WhatsApp for a cohesive look.',
    'manage_accounts': 'Manage Accounts',
    'add_account': 'Add account',
    'always_show_tab_bar': 'Always show tab bar',
    'updates': 'Updates',
    'check_updates_launch': 'Check for updates on launch',
    'check_now': 'Check Now',
    'devtools': 'DevTools',
    'debug_active_tab': 'Debug active tab',
    'delete_account_title': 'Delete Account',
    'delete_account_confirm': 'Delete "{name}"? This will remove all data for this account.',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'rename': 'Rename',
    'language': 'Language',
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

  static Future<Map<String, String>> fetchTranslations(String targetLang) async {
    if (targetLang == 'en') {
      return enStrings;
    }

    final Map<String, String> translated = {};
    final client = HttpClient();

    for (final entry in enStrings.entries) {
      if (entry.key == 'delete_account_confirm') {
        // Skip template replacement placeholder during translation to avoid translation API messing with it
        final textToTranslate = entry.value.replaceAll('{name}', '___');
        final translatedText = await _translateText(client, textToTranslate, targetLang);
        translated[entry.key] = translatedText.replaceAll('___', '{name}');
      } else {
        translated[entry.key] = await _translateText(client, entry.value, targetLang);
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

  static Future<String> _translateText(HttpClient client, String text, String targetLang) async {
    try {
      final uri = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}');
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
