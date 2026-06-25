import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:whatsapp/constants.dart' as constants;
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/manager/localization.dart';
import 'package:window_manager/window_manager.dart';
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
    final params = WindowsPlatformWebViewControllerCreationParams(
      userDataFolder: sharedDataDirectory,
      profileName: id,
    );
    _webViewController = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        var req = request.platform as WinWebViewPermissionRequest;
        final isNotification =
            req.kind == WinWebViewPermissionResourceType.notification;
        if (req.url.contains("whatsapp")) {
          req.grant();
          if (isNotification) {
            _webViewController?.reload();
          }
        } else if (isNotification) {
          req.grant();
          _webViewController?.reload();
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

    // Register Translation JS Channel to bypass CORS block on fetch
    _webViewController!.addJavaScriptChannel(
      'TranslationChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        try {
          final data = jsonDecode(message.message) as Map<String, dynamic>;
          final type = data['type'] as String?;
          final targetLang = data['targetLang'] as String;

          if (type == 'BATCH_TRANSLATE') {
            final transId = data['id'] as String;
            final texts = List<String>.from(data['texts'] as List);

            // Join segments with \n###\n
            final combinedText = texts.join('\n###\n');
            final result = await AppLocalizations.translateSingle(
                combinedText, targetLang);

            final RegExp separatorPattern = RegExp(r'\n\s*###\s*\n');
            final translatedParts = result.split(separatorPattern);

            final List<String> cleanParts = [];
            for (var i = 0; i < texts.length; i++) {
              String part =
                  i < translatedParts.length ? translatedParts[i] : texts[i];
              if (part.isEmpty) part = texts[i];
              cleanParts.add(part);
            }
            final partsJson = jsonEncode(cleanParts);
            await _webViewController!.runJavaScript(
                "if (window.onBatchTranslationReceived) { window.onBatchTranslationReceived('$transId', $partsJson, true); }");
          } else {
            final transId = data['id'] as String;
            final text = data['text'] as String;
            final result =
                await AppLocalizations.translateSingle(text, targetLang);
            final jsonResult = jsonEncode(result);

            await _webViewController!.runJavaScript(
                "if (window.onTranslationReceived) { window.onTranslationReceived('$transId', $jsonResult, true); }");
          }
        } catch (e) {
          debugPrint('Error handling translation bridge: $e');
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            final transId = data['id'] as String;
            final type = data['type'] as String?;
            if (type == 'BATCH_TRANSLATE') {
              await _webViewController!.runJavaScript(
                  "if (window.onBatchTranslationReceived) { window.onBatchTranslationReceived('$transId', [], false); }");
            } else {
              await _webViewController!.runJavaScript(
                  "if (window.onTranslationReceived) { window.onTranslationReceived('$transId', '', false); }");
            }
          } catch (_) {}
        }
      },
    );

    // Register a JavaScript channel to receive notification events
    _webViewController!.addJavaScriptChannel(
      'NotificationChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        try {
          final data = jsonDecode(message.message) as Map<String, dynamic>;
          final type = data['type'] as String;

          if (type == 'NOTIFICATION_RECEIVED') {
            final notificationId = data['id'] as String;
            _activeNotificationIds.add(notificationId);

            hasNotification = true;
            onNotificationChanged?.call(id, true);

            final String originalTitle = data['title'] as String? ?? '';
            final String originalBody = data['body'] as String? ?? '';

            // Handle translation based on settings
            String displayBody = originalBody;
            if (settingsController.translateNotifications &&
                settingsController.language != 'en') {
              try {
                displayBody = await AppLocalizations.translateSingle(
                    originalBody, settingsController.language);
              } catch (e) {
                debugPrint('Failed to translate notification body: $e');
              }
            }

            final List<LocalNotificationAction> actions = [];
            if (!settingsController.translateNotifications &&
                settingsController.showTranslateNotificationButton &&
                settingsController.language != 'en') {
              actions.add(LocalNotificationAction(text: 'Translate'));
            }

            final localNotif = LocalNotification(
              title: originalTitle,
              body: displayBody,
              actions: actions,
            );

            localNotif.onClick = () async {
              debugPrint('LocalNotification onClick: $notificationId');
              _activeNotificationIds.remove(notificationId);
              _nativeNotifications.remove(notificationId);
              hasNotification = _activeNotificationIds.isNotEmpty;
              onNotificationChanged?.call(id, hasNotification);

              // Restore and focus the window
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
              // Dispatch notification click event to JS
              await _webViewController?.runJavaScript(
                  "if (window.onNotificationClicked) { window.onNotificationClicked('$notificationId'); }");
            };

            localNotif.onClose = (closeReason) async {
              debugPrint('LocalNotification onClose: $notificationId, reason: $closeReason');
              if (closeReason == LocalNotificationCloseReason.timedOut) {
                // If it timed out, it went to the Action Center, so keep it active!
                return;
              }
              _activeNotificationIds.remove(notificationId);
              _nativeNotifications.remove(notificationId);
              hasNotification = _activeNotificationIds.isNotEmpty;
              onNotificationChanged?.call(id, hasNotification);

              await _webViewController?.runJavaScript(
                  "if (window.onNotificationClosedFromServer) { window.onNotificationClosedFromServer('$notificationId'); }");
            };

            if (actions.isNotEmpty) {
              localNotif.onClickAction = (actionIndex) async {
                debugPrint('LocalNotification onClickAction: $notificationId, index: $actionIndex');
                if (actionIndex == 0) {
                  // "Translate" was clicked
                  localNotif.onClose = (reason) {
                    debugPrint('LocalNotification overridden onClose ran for: $notificationId');
                  }; // Disable close tracking temporarily for this native popup
                  await localNotif.close();
                  _nativeNotifications.remove(notificationId);

                  String translatedBody = originalBody;
                  try {
                    translatedBody = await AppLocalizations.translateSingle(
                        originalBody, settingsController.language);
                  } catch (e) {
                    debugPrint('Failed to translate notification body: $e');
                  }

                  final translatedNotif = LocalNotification(
                    title: originalTitle,
                    body: translatedBody,
                  );

                  translatedNotif.onClick = localNotif.onClick;
                  translatedNotif.onClose = (closeReason) async {
                    debugPrint('TranslatedNotification onClose: $notificationId, reason: $closeReason');
                    if (closeReason == LocalNotificationCloseReason.timedOut) {
                      // Keep it active in the Action Center
                      return;
                    }
                    _activeNotificationIds.remove(notificationId);
                    _nativeNotifications.remove(notificationId);
                    hasNotification = _activeNotificationIds.isNotEmpty;
                    onNotificationChanged?.call(id, hasNotification);

                    await _webViewController?.runJavaScript(
                        "if (window.onNotificationClosedFromServer) { window.onNotificationClosedFromServer('$notificationId'); }");
                  };
                  _nativeNotifications[notificationId] = translatedNotif;
                  await translatedNotif.show();
                }
              };
            }

            _nativeNotifications[notificationId] = localNotif;
            await localNotif.show();
          } else if (type == 'NOTIFICATION_CLOSED') {
            final notificationId = data['id'] as String;
            debugPrint('NOTIFICATION_CLOSED from JS: $notificationId');
            _activeNotificationIds.remove(notificationId);
            final nativeNotif = _nativeNotifications.remove(notificationId);
            if (nativeNotif != null) {
              await nativeNotif.close();
            }
            hasNotification = _activeNotificationIds.isNotEmpty;
            onNotificationChanged?.call(id, hasNotification);
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
      onPageFinished: (url) async {
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

        final lang = settingsController.supportedLanguages.firstWhere(
          (l) => l['code'] == settingsController.language,
          orElse: () => {'name': 'English', 'code': 'en'},
        );
        String translatedLangName = lang['name']!;
        if (settingsController.language != 'en') {
          try {
            translatedLangName = await AppLocalizations.translateSingle(
                lang['name']!, settingsController.language);
          } catch (_) {}
        }
        final tooltipLabel = settingsController.localizations
            .get('translate_to_lang', args: {'lang': translatedLangName});

        // Inject translation script with current language settings pre-populated
        _webViewController!.runJavaScript(constants.getTranslationJS(
          settingsController.language,
          translatedLangName,
          tooltipLabel,
          settingsController.translateMessageButton,
          settingsController.fullPageTranslation,
        ));
      },
      onWebResourceError: (error) =>
          debugPrint("onWebResourceError: ${error.description}"),
    ));
    _webViewController!.loadRequest(Uri.parse("https://web.whatsapp.com/"));
    _webViewSetupDone = true;
    debugPrint('webView set up for account $id');
  }
}
