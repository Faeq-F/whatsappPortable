import 'dart:convert';

abstract class JsPayload {}

class JsTranslationPayload implements JsPayload {
  final String id;
  final String targetLang;
  final String? type;
  final String? text;
  final List<String>? texts;

  JsTranslationPayload({
    required this.id,
    required this.targetLang,
    this.type,
    this.text,
    this.texts,
  });

  factory JsTranslationPayload.fromJson(String jsonStr) {
    final Map<String, dynamic> map = jsonDecode(jsonStr);
    
    final id = map['id'] as String?;
    final targetLang = map['targetLang'] as String?;
    
    if (id == null || targetLang == null) {
      throw FormatException('Missing required fields id or targetLang in translation payload: $jsonStr');
    }
    
    final type = map['type'] as String?;
    final text = map['text'] as String?;
    final textsList = map['texts'] as List?;
    
    List<String>? texts;
    if (textsList != null) {
      texts = List<String>.from(textsList);
    }
    
    return JsTranslationPayload(
      id: id,
      targetLang: targetLang,
      type: type,
      text: text,
      texts: texts,
    );
  }
}

class JsNotificationPayload implements JsPayload {
  final String id;
  final String type;
  final String? title;
  final String? body;

  JsNotificationPayload({
    required this.id,
    required this.type,
    this.title,
    this.body,
  });

  factory JsNotificationPayload.fromJson(String jsonStr) {
    final Map<String, dynamic> map = jsonDecode(jsonStr);
    
    final id = map['id'] as String?;
    final type = map['type'] as String?;
    
    if (id == null || type == null) {
      throw FormatException('Missing required fields id or type in notification payload: $jsonStr');
    }
    
    final title = map['title'] as String?;
    final body = map['body'] as String?;
    
    return JsNotificationPayload(
      id: id,
      type: type,
      title: title,
      body: body,
    );
  }
}
