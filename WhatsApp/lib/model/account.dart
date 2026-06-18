import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:whatsapp/constants.dart' as constants;
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:window_manager/window_manager.dart';

class WhatsAppAccount {
  final String id;
  String name;
  WebViewController? _webViewController;
  bool isActive;
  bool _webViewSetupDone = false;
  bool hasNotification = false;

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
    final params = WindowsPlatformWebViewControllerCreationParams(
      userDataFolder: sharedDataDirectory,
      profileName: id,
    );
    _webViewController = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        var req = request.platform as WinWebViewPermissionRequest;
        if (req.url.contains("whatsapp")) {
          req.grant();
        } else if (req.kind == WinWebViewPermissionResourceType.notification) {
          req.grant();
        } else {
          req.deny();
        }
        debugPrint("permission: ${req.kind} , ${req.url}");
      },
    );
    debugPrint('webViewController initialized for account $id');
  }

  Future<void> ensureSharedDataDirectory() async {
    final directory = Directory(sharedDataDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
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

    // Register a JavaScript channel to receive notification events
    _webViewController!.addJavaScriptChannel(
      'NotificationChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        try {
          final data = jsonDecode(message.message) as Map<String, dynamic>;
          final type = data['type'] as String;
          final remainingCount = data['remainingCount'] as int? ?? 0;

          if (type == 'NOTIFICATION_RECEIVED') {
            hasNotification = true;
            debugPrint('Notification received on account $id: ${data['title']}');
            onNotificationChanged?.call(id, true);
          } else if (type == 'NOTIFICATION_CLOSED') {
            hasNotification = remainingCount > 0;
            debugPrint('Notification closed on account $id, remaining: $remainingCount');
            onNotificationChanged?.call(id, hasNotification);
          } else if (type == 'NOTIFICATION_CLICKED') {
            debugPrint('Notification clicked on account $id');
            try {
              if (await windowManager.isMinimized()) {
                await windowManager.restore();
              }
              await windowManager.show();
              await windowManager.focus();
              await windowManager.setAlwaysOnTop(true);
              await windowManager.setAlwaysOnTop(false);
            } catch (e) {
              debugPrint('Error showing window on notification click: $e');
            }
          }
        } catch (e) {
          debugPrint('Error parsing notification message: $e');
        }
      },
    );

    _webViewController!.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (request) {
        var launch = NavigationDecision.navigate;
        if (!request.url.contains("whatsapp")) {
          launchUrl(Uri.parse(request.url));
          launch = NavigationDecision.prevent;
        }
        return launch;
      },
      onPageFinished: (url) {
        final brightness = settingsController.themeMode == ThemeMode.system
            ? WidgetsBinding.instance.platformDispatcher.platformBrightness
            : (settingsController.themeMode == ThemeMode.light
                ? Brightness.light
                : Brightness.dark);
        if (brightness == Brightness.light) {
          _webViewController!.runJavaScript(constants.lightModeJS);
        } else {
          _webViewController!.runJavaScript(constants.darkModeJS);
        }

        // Inject notification override script
        _webViewController!.runJavaScript(constants.notificationOverrideJS);
      },
      onWebResourceError: (error) =>
          debugPrint("onWebResourceError: ${error.description}"),
    ));
    _webViewController!.loadRequest(Uri.parse("https://web.whatsapp.com/"));
    _webViewSetupDone = true;
    debugPrint('webView set up for account $id');
  }
}
