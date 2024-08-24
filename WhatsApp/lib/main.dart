import 'package:flutter/material.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:window_manager/window_manager.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final controller = WinWebViewController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setTitle("WhatsApp");
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  runApp(const WhatsApp());
}

class WhatsApp extends StatelessWidget {
  const WhatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(
            //Here you can set what ever background color you need.
            backgroundColor: Colors.white,
            body: Browser()),
        title: 'WhatsApp');
  }
}

class Browser extends StatefulWidget {
  const Browser({super.key});

  @override
  State<Browser> createState() => _Browser();
}

class _Browser extends State<Browser> {
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadRequest(Uri.parse("https://web.whatsapp.com/"));
    controller.runJavaScript("""
      window.onload = function () {
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
      };
    """);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            const Card(
                color: Colors.white,
                elevation: 0,
                child: DraggableAppBar(
                    title: "WhatsApp",
                    brightness: Brightness.light,
                    backgroundColor: Colors.white)),
            Expanded(
                child: Card(
                    color: Colors.white,
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
                    icon: const Icon(Icons.developer_mode),
                    tooltip: 'Open DevTools',
                    iconSize: 15,
                    splashRadius: 20,
                    onPressed: () {
                      controller.openDevTools();
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
          child: Text(title),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(20);
}
