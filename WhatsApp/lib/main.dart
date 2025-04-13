import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:whatsapp/settings_controller.dart';
import 'package:whatsapp/settings_service.dart';
import 'package:whatsapp/top_bar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:async';
import 'dart:io';
import 'package:get_it/get_it.dart';

import 'constants.dart' as constants;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Register Services
  final settingsService = await SettingsService.getInstance();
  GetIt.I.registerSingleton<SettingsService>(settingsService);
  final settingsController = SettingsController(settingsService);

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  await windowManager.ensureInitialized();
  await windowManager.setTitle("WhatsApp");
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setPreventClose(true);

  runApp(WhatsApp(settingsController: settingsController));
}

class WhatsApp extends StatelessWidget with TrayListener {
  final SettingsController settingsController;

  WhatsApp({
    super.key,
    required this.settingsController,
  }) {
    createTrayTask();
    trayManager.addListener(this);
  }

  @override
  void onTrayIconMouseDown() async {
    await toggleWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  Future<void> toggleWindow() async {
    if (await windowManager.isVisible()) {
      await windowManager.hide();
    } else {
      await windowManager.show();
    }
  }

  Future<void> createTrayTask() async {
    String iconPath = 'images/icon.ico';
    await trayManager.setIcon(iconPath);
    await trayManager.setToolTip('WhatsApp');
    Menu menu = Menu(
      items: [
        MenuItem(
            label: 'Toggle Window',
            onClick: (MenuItem item) async {
              await toggleWindow();
            }),
        MenuItem.separator(),
        MenuItem(
            label: 'Exit',
            onClick: (MenuItem item) {
              exit(0);
            })
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'app',
              supportedLocales: const [
                Locale('en', ''), // English, no country code
              ],
              //themes defined
              theme: constants.lightTheme,
              darkTheme: constants.darkTheme,
              themeMode: settingsController.themeMode,
              navigatorKey: constants.navigatorKey,
              home: Scaffold(
                  body: Browser(
                settingsController: settingsController,
              )),
              title: 'WhatsApp');
        });
  }
}

class Browser extends StatefulWidget {
  final SettingsController settingsController;
  const Browser({super.key, required this.settingsController});

  @override
  State<Browser> createState() =>
      _Browser(settingsController: settingsController);
}

class _Browser extends State<Browser> with WindowListener {
  final SettingsController settingsController;
  _Browser({required this.settingsController});

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    }
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    constants.browserController.setNavigationDelegate(WinNavigationDelegate(
      onNavigationRequest: (request) {
        var launch = NavigationDecision.navigate;
        if (!request.url.contains("whatsapp")) {
          launchUrl(Uri.parse(request.url));
          launch = NavigationDecision.prevent;
        }
        return launch;
      },
      onPageFinished: (url) => {
        if (Theme.of(context).brightness == Brightness.light)
          {constants.browserController.runJavaScript(constants.lightModeJS)}
        else
          {constants.browserController.runJavaScript(constants.darkModeJS)}
      },
      onWebResourceError: (error) =>
          debugPrint("onWebResourceError: ${error.description}"),
    ));
    constants.browserController.loadRequest_("https://web.whatsapp.com/");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Card(
                color: (Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black),
                elevation: 0,
                child: DraggableAppBar(
                  settingsController: settingsController,
                )),
            Expanded(
                child: Card(
                    color: (Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black),
                    elevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      children: [
                        WinWebViewWidget(
                            controller: constants.browserController)
                      ],
                    ))),
          ],
        ),
      )),
    );
  }
}
