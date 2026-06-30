import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/manager/localization.dart';
import 'package:whatsapp/manager/js_scripts/theme.dart';
import 'package:whatsapp/manager/js_scripts/notification.dart';
import 'package:whatsapp/manager/js_scripts/translation.dart';
import 'package:whatsapp/model/webview_payload.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_notifier/local_notifier.dart';

class WebviewBridgeManager {
  static WebViewController createController({
    required String accountId,
    required String userDataFolder,
  }) {
    late final WebViewController controller;

    final params = WindowsPlatformWebViewControllerCreationParams(
      userDataFolder: userDataFolder,
      profileName: accountId,
    );

    controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        var req = request.platform as WinWebViewPermissionRequest;
        final isNotification =
            req.kind == WinWebViewPermissionResourceType.notification;
        if (req.url.contains("whatsapp")) {
          req.grant();
          if (isNotification) {
            controller.reload();
          }
        } else if (isNotification) {
          req.grant();
          controller.reload();
        } else {
          req.deny();
        }
        debugPrint("permission: ${req.kind} , ${req.url}");
      },
    );

    return controller;
  }

  static void setupWebView({
    required WebViewController controller,
    required String accountId,
    required SettingsController settingsController,
    required Set<String> activeNotificationIds,
    required Map<String, LocalNotification> nativeNotifications,
    required Function(bool hasNotification) onNotificationChanged,
  }) {
    // Register Translation JS Channel to bypass CORS block on fetch
    controller.addJavaScriptChannel(
      'TranslationChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        JsTranslationPayload? payload;
        try {
          payload = JsTranslationPayload.fromJson(message.message);

          if (payload.type == 'BATCH_TRANSLATE') {
            final texts = payload.texts ?? [];
            final combinedText = texts.join('\n###\n');
            final result = await AppLocalizations.translateSingle(
                combinedText, payload.targetLang);

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
            await controller.runJavaScript(
                "if (window.onBatchTranslationReceived) { window.onBatchTranslationReceived('${payload.id}', $partsJson, true); }");
          } else {
            final text = payload.text ?? '';
            final String result;
            if (payload.quotedText != null) {
              final translatedQuoted = await AppLocalizations.translateSingle(payload.quotedText!, payload.targetLang);
              final translatedResponse = await AppLocalizations.translateSingle(text, payload.targetLang);
              result = jsonEncode({
                'quoted': translatedQuoted,
                'response': translatedResponse,
              });
            } else {
              result = await AppLocalizations.translateSingle(text, payload.targetLang);
            }
            final jsonResult = jsonEncode(result);

            await controller.runJavaScript(
                "if (window.onTranslationReceived) { window.onTranslationReceived('${payload.id}', $jsonResult, true); }");
          }
        } catch (e) {
          debugPrint('Error handling translation bridge: $e');
          if (payload != null) {
            try {
              if (payload.type == 'BATCH_TRANSLATE') {
                await controller.runJavaScript(
                    "if (window.onBatchTranslationReceived) { window.onBatchTranslationReceived('${payload.id}', [], false); }");
              } else {
                await controller.runJavaScript(
                    "if (window.onTranslationReceived) { window.onTranslationReceived('${payload.id}', '', false); }");
              }
            } catch (_) {}
          } else {
            try {
              final data = jsonDecode(message.message) as Map<String, dynamic>;
              final transId = data['id'] as String;
              final type = data['type'] as String?;
              if (type == 'BATCH_TRANSLATE') {
                await controller.runJavaScript(
                    "if (window.onBatchTranslationReceived) { window.onBatchTranslationReceived('$transId', [], false); }");
              } else {
                await controller.runJavaScript(
                    "if (window.onTranslationReceived) { window.onTranslationReceived('$transId', '', false); }");
              }
            } catch (_) {}
          }
        }
      },
    );

    // Register a JavaScript channel to receive notification events
    controller.addJavaScriptChannel(
      'NotificationChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        try {
          final payload = JsNotificationPayload.fromJson(message.message);

          if (payload.type == 'NOTIFICATION_RECEIVED') {
            final notificationId = payload.id;
            activeNotificationIds.add(notificationId);

            onNotificationChanged(true);

            final String originalTitle = payload.title ?? '';
            final String originalBody = payload.body ?? '';

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
              activeNotificationIds.remove(notificationId);
              nativeNotifications.remove(notificationId);
              onNotificationChanged(activeNotificationIds.isNotEmpty);

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
              await controller.runJavaScript(
                  "if (window.onNotificationClicked) { window.onNotificationClicked('$notificationId'); }");
            };

            localNotif.onClose = (closeReason) async {
              debugPrint('LocalNotification onClose: $notificationId, reason: $closeReason');
              if (closeReason == LocalNotificationCloseReason.timedOut) {
                return;
              }
              activeNotificationIds.remove(notificationId);
              nativeNotifications.remove(notificationId);
              onNotificationChanged(activeNotificationIds.isNotEmpty);

              await controller.runJavaScript(
                  "if (window.onNotificationClosedFromServer) { window.onNotificationClosedFromServer('$notificationId'); }");
            };

            if (actions.isNotEmpty) {
              localNotif.onClickAction = (actionIndex) async {
                debugPrint('LocalNotification onClickAction: $notificationId, index: $actionIndex');
                if (actionIndex == 0) {
                  localNotif.onClose = (reason) {
                    debugPrint('LocalNotification overridden onClose ran for: $notificationId');
                  };
                  await localNotif.close();
                  nativeNotifications.remove(notificationId);

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
                      return;
                    }
                    activeNotificationIds.remove(notificationId);
                    nativeNotifications.remove(notificationId);
                    onNotificationChanged(activeNotificationIds.isNotEmpty);

                    await controller.runJavaScript(
                        "if (window.onNotificationClosedFromServer) { window.onNotificationClosedFromServer('$notificationId'); }");
                  };
                  nativeNotifications[notificationId] = translatedNotif;
                  await translatedNotif.show();
                }
              };
            }

            nativeNotifications[notificationId] = localNotif;
            await localNotif.show();
          } else if (payload.type == 'NOTIFICATION_CLOSED') {
            final notificationId = payload.id;
            debugPrint('NOTIFICATION_CLOSED from JS: $notificationId');
            activeNotificationIds.remove(notificationId);
            final nativeNotif = nativeNotifications.remove(notificationId);
            if (nativeNotif != null) {
              await nativeNotif.close();
            }
            onNotificationChanged(activeNotificationIds.isNotEmpty);
          }
        } catch (e) {
          debugPrint('Error parsing notification message: $e');
        }
      },
    );

    controller.setNavigationDelegate(NavigationDelegate(
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
          controller.runJavaScript(ThemeJsScripts.lightModeJS);
        } else {
          controller.runJavaScript(ThemeJsScripts.darkModeJS);
        }

        controller.runJavaScript(NotificationJsScripts.notificationOverrideJS);

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

        controller.runJavaScript(TranslationJsScripts.getTranslationJS(
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

    controller.loadRequest(Uri.parse("https://web.whatsapp.com/"));
  }
}
