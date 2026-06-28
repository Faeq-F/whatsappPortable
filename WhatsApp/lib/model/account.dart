import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/manager/webview_bridge_manager.dart';
import 'package:local_notifier/local_notifier.dart';

class WhatsAppAccount {
  final String id;
  String name;
  WebViewController? _webViewController;
  bool isActive;
  bool _webViewSetupDone = false;
  bool hasNotification = false;
  final Set<String> _activeNotificationIds = {};
  final Map<String, LocalNotification> _nativeNotifications = {};

  static String get sharedDataDirectory =>
      '${Directory.current.path}\\data\\webview';

  static String generateId() =>
      'account_${DateTime.now().millisecondsSinceEpoch}';

  WhatsAppAccount({
    required this.id,
    required this.name,
    this.isActive = false,
  });

  WebViewController get webViewController {
    if (_webViewController == null) {
      throw StateError(
          'webViewController accessed before initialization for account $id');
    }
    return _webViewController!;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  factory WhatsAppAccount.fromJson(Map<String, dynamic> json) {
    return WhatsAppAccount(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'] ?? false,
    );
  }

  void initializeWebViewController() {
    if (_webViewController != null) {
      debugPrint(
          'webViewController already initialized for account $id, skipping');
      return;
    }
    debugPrint("Initializing WebViewController with profileName: $id");
    _webViewController = WebviewBridgeManager.createController(
      accountId: id,
      userDataFolder: sharedDataDirectory,
    );
    debugPrint('webViewController initialized for account $id');
  }

  Future<void> ensureSharedDataDirectory() async {
    final directory = Directory(sharedDataDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> updateWebviewLanguage(String langCode, String langName,
      String translateTooltipLabel, bool enableHover) async {
    if (_webViewController == null) return;
    try {
      await _webViewController!.runJavaScript(
          "if (window.setTargetLanguage) { window.setTargetLanguage('$langCode', '$langName', '$translateTooltipLabel', $enableHover); }");
    } catch (e) {
      debugPrint('Failed to update webview language in JS: $e');
    }
  }

  void setupWebView(
    SettingsController settingsController, {
    Function(String accountId, bool hasNotification)? onNotificationChanged,
  }) {
    if (_webViewSetupDone) {
      debugPrint('webView already set up for account $id, skipping');
      return;
    }

    WebviewBridgeManager.setupWebView(
      controller: webViewController,
      accountId: id,
      settingsController: settingsController,
      activeNotificationIds: _activeNotificationIds,
      nativeNotifications: _nativeNotifications,
      onNotificationChanged: (hasNotif) {
        hasNotification = hasNotif;
        onNotificationChanged?.call(id, hasNotif);
      },
    );

    _webViewSetupDone = true;
    debugPrint('webView set up for account $id');
  }
}
