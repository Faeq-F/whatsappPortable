import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:whatsapp/ui/browser.dart';
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/manager/localization.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:io';
import 'constants.dart' as constants;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await localNotifier.setup(
    appName: 'WhatsApp',
  );

  final settingsController = SettingsController();


  await settingsController.loadSettings();
  await windowManager.ensureInitialized();
  await windowManager.setTitle("WhatsApp");
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setPreventClose(true);

  runApp(WhatsApp(settingsController: settingsController));
}

class WhatsApp extends StatefulWidget {
  final SettingsController settingsController;

  const WhatsApp({
    super.key,
    required this.settingsController,
  });

  @override
  State<WhatsApp> createState() => _WhatsAppState();
}

class _WhatsAppState extends State<WhatsApp> with TrayListener {
  @override
  void initState() {
    super.initState();
    createTrayTask();
    trayManager.addListener(this);
    widget.settingsController.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    widget.settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    createTrayTask();
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
    final loc = widget.settingsController.localizations;
    Menu menu = Menu(
      items: [
        MenuItem(
            label: loc.get('toggle_window'),
            onClick: (MenuItem item) async {
              await toggleWindow();
            }),
         MenuItem.separator(),
        MenuItem(
            label: loc.get('exit'),
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
        listenable: widget.settingsController,
        builder: (BuildContext context, Widget? child) {
          final isRtl = !widget.settingsController.keepAppInEnglish &&
              AppLanguages.isRtl(widget.settingsController.language);
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'app',
              supportedLocales: const [Locale('en', '')],
              theme: constants.lightTheme,
              darkTheme: constants.darkTheme,
              themeMode: widget.settingsController.themeMode,
              navigatorKey: constants.navigatorKey,
              home: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Scaffold(
                    body: Browser(
                  settingsController: widget.settingsController,
                )),
              ),
              title: 'WhatsApp');
        });
  }
}
