import 'package:flutter/material.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:process_run/process_run.dart';
import 'dart:async';
import 'dart:io';

final navigatorKey = GlobalKey<NavigatorState>();
WinWebViewController controller = WinWebViewController();

SharedPreferences? appPrefs;

enum Theme { dark, light }

Theme theme = Theme.dark;

Future<void> runCustomJS() async {
  await controller.loadRequest_("https://web.whatsapp.com/");
  if (theme == Theme.light) {
    await controller.runJavaScript("""
      window.onload = () => {
        var style = document.createElement("style");
        style.innerHTML =

          ".app-wrapper-web ._aigs {" +
            "top: 0 !important;" +
            "width: 100vw !important;" +
            "height: 100vh !important;" +
            "max-width: 100vw !important;" +
            "margin: 0 !important;" +
            "box-shadow: 0 !important;" +
          "}"+

          "._al_d{"+
            "display: none !important;"+
          "}"+

          "#app{"+
            "border-radius: 15px !important;"+
          "}"+

          "body{"+
            "background:#fff !important;"+
          "}"+

          "._ap4q::after {"+
            "background-color: #fff !important;"+
          "}";
        var ref = document.querySelector("script");
        ref.parentNode.insertBefore(style, ref);
        document.getElementsByTagName("body")[0].classList = [""];
        console.log("ran");
      }
    """);
  } else {
    await controller.runJavaScript("""
      window.onload = () => {
        var style = document.createElement("style");
        style.innerHTML =

          ".app-wrapper-web ._aigs {" +
            "top: 0 !important;" +
            "width: 100vw !important;" +
            "height: 100vh !important;" +
            "max-width: 100vw !important;" +
            "margin: 0 !important;" +
            "box-shadow: 0 !important;" +
          "}"+

          "._al_d{"+
            "display: none !important;"+
          "}"+

          "#app{"+
            "border-radius: 15px !important;"+
          "}"+

          "body{"+
            "background:#000 !important;"+
          "}"+

          "._ap4q::after {"+
            "background-color: #000 !important;"+
          "}";
        var ref = document.querySelector("script");
        ref.parentNode.insertBefore(style, ref);
        document.getElementsByTagName("body")[0].classList = ["dark"];
        console.log("ran");
      }
    """);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  appPrefs = await SharedPreferences.getInstance();
  String? savedTheme = appPrefs!.getString('theme');
  if (savedTheme != null) {
    if (savedTheme == "Theme.light") {
      theme = Theme.light;
    } else {
      theme = Theme.dark;
    }
  } else {
    theme = Theme.dark;
  }
  await appPrefs!.setString('theme', theme.toString());
  await windowManager.ensureInitialized();
  await windowManager.setTitle("WhatsApp");
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setPreventClose(true);
  runApp(WhatsApp());
}

class WhatsApp extends StatelessWidget with TrayListener {
  WhatsApp({super.key}) {
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
    return MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
            backgroundColor:
                (theme == Theme.light) ? Colors.white : Colors.black,
            body: const Browser()),
        title: 'WhatsApp');
  }
}

class Browser extends StatefulWidget {
  const Browser({super.key});

  @override
  State<Browser> createState() => _Browser();
}

class _Browser extends State<Browser> with WindowListener {
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
    runCustomJS();
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
                color: (theme == Theme.light) ? Colors.white : Colors.black,
                elevation: 0,
                child: DraggableAppBar(
                  title: "WhatsApp",
                  brightness: (theme == Theme.light)
                      ? Brightness.light
                      : Brightness.dark,
                  backgroundColor:
                      (theme == Theme.light) ? Colors.white : Colors.black,
                )),
            Expanded(
                child: Card(
                    color: (theme == Theme.light) ? Colors.white : Colors.black,
                    elevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      children: [WinWebViewWidget(controller: controller)],
                    ))),
          ],
        ),
      )),
    );
  }
}

class DraggableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Brightness brightness;
  final Color backgroundColor;

  const DraggableAppBar({
    super.key,
    required this.title,
    required this.brightness,
    required this.backgroundColor,
  });

  Future<void> toggleTheme() async {
    String? savedTheme = appPrefs!.getString('theme');
    if (savedTheme != null) {
      if (savedTheme == "Theme.light") {
        theme = Theme.dark;
      } else {
        theme = Theme.light;
      }
    } else {
      theme = Theme.dark;
    }
    await appPrefs!.setString('theme', theme.toString());
    var shell = Shell();
    await shell.run("powershell.exe scripts/restartApp.ps1");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(children: [
              SizedBox(
                  height: 20,
                  width: 20,
                  child: IconButton(
                    color: (theme == Theme.light)
                        ? Colors.black54
                        : Colors.white60,
                    icon: const Icon(Icons.developer_mode),
                    tooltip: 'Open DevTools',
                    iconSize: 15,
                    onPressed: () {
                      controller.openDevTools();
                    },
                  )),
              SizedBox(
                  height: 20,
                  width: 20,
                  child: IconButton(
                    color: (theme == Theme.light)
                        ? Colors.black54
                        : Colors.white60,
                    icon: const Icon(Icons.lightbulb_outlined),
                    tooltip: 'Change Theme',
                    iconSize: 15,
                    onPressed: () async {
                      await toggleTheme();
                    },
                  )),
            ])),
        getAppBarTitle(title),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizedBox(
            height: 20,
            width: 200,
            child: WindowCaption(
              backgroundColor: backgroundColor,
              brightness: brightness,
            ),
          ),
        )
      ],
    );
  }

  Widget getAppBarTitle(String title) {
    return DragToMoveArea(
      child: SizedBox(
        height: 20,
        child: Align(
          alignment: AlignmentDirectional.center,
          child: Text(title,
              style: TextStyle(
                color: (theme == Theme.light) ? Colors.black : Colors.white,
              )),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(20);
}
