import 'package:flutter/material.dart';
import 'package:whatsapp/browser.dart';
import 'package:whatsapp/settings_controller.dart';
import 'package:whatsapp/settings_service.dart';
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
