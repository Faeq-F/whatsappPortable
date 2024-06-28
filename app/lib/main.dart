import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final _controller = WebviewController();

void main() async {
  // For full-screen example
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setTitle("WhatsApp");
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(
            //Here you can set what ever background color you need.
            backgroundColor: Colors.white,
            body: ExampleBrowser()),
        title: 'WhatsApp');
  }
}

class ExampleBrowser extends StatefulWidget {
  const ExampleBrowser({super.key});

  @override
  State<ExampleBrowser> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<ExampleBrowser> {
  final _textController = TextEditingController();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      await _controller.initialize();

      // The Whatsapp web site has useless space around the app - this removes it
      // also adds styles that make the site look cleaner
      var expandScript = '''
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
                              "}";
                            var ref = document.querySelector("script");
                            ref.parentNode.insertBefore(style, ref);
                          };
                          ''';
      _controller.addScriptToExecuteOnDocumentCreated(expandScript);

      _subscriptions.add(_controller.url.listen((url) {
        _textController.text = url;
      }));

      _subscriptions
          .add(_controller.containsFullScreenElementChanged.listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      }));

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl('https://web.whatsapp.com');

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Card(
                color: Colors.white,
                elevation: 0,
                child: new DraggableAppBar(
                    title: "WhatsApp",
                    brightness: Brightness.light,
                    backgroundColor: Colors.white)),
            Expanded(
                child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      children: [
                        Webview(
                          _controller,
                          permissionRequested: _onPermissionRequested,
                        ),
                        StreamBuilder<LoadingState>(
                            stream: _controller.loadingState,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data == LoadingState.loading) {
                                return const LinearProgressIndicator();
                              } else {
                                return const SizedBox();
                              }
                            }),
                      ],
                    ))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: compositeView(),
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WhatsApp permission requested'),
        content: Text('WhatsApp has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

  @override
  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _controller.dispose();
    super.dispose();
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
                      _controller.openDevTools();
                    },
                  )),
              SizedBox(
                  height: 20,
                  width: 20,
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    iconSize: 15,
                    splashRadius: 20,
                    onPressed: () {
                      _controller.reload();
                    },
                  ))
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
