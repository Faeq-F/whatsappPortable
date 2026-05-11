import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:whatsapp/constants.dart' as constants;
import 'package:whatsapp/manager/settings_controller.dart';

class WhatsAppAccount {
  final String id;
  String name;
  WebViewController? _webViewController;
  bool isActive;
  bool _webViewSetupDone = false;

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
        if (req.kind == WinWebViewPermissionResourceType.notification) {
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

  void setupWebView(SettingsController settingsController) {
    if (_webViewSetupDone) {
      debugPrint('webView already set up for account $id, skipping');
      return;
    }
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
      },
      onWebResourceError: (error) =>
          debugPrint("onWebResourceError: ${error.description}"),
    ));
    _webViewController!.loadRequest(Uri.parse("https://web.whatsapp.com/"));
    _webViewSetupDone = true;
    debugPrint('webView set up for account $id');
  }
}
