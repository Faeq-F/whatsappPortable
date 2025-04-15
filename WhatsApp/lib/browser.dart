import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatsapp/settings_controller.dart';
import 'package:whatsapp/top_bar.dart';
import 'package:window_manager/window_manager.dart';
import 'constants.dart' as constants;

class Browser extends StatefulWidget {
  final SettingsController settingsController;
  const Browser({super.key, required this.settingsController});

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

    constants.browserController.setNavigationDelegate(NavigationDelegate(
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
    constants.browserController.loadRequest(Uri.parse(
        "https://web.whatsapp.com/")); //.loadRequest_("https://web.whatsapp.com/");
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
                color: Theme.of(context).cardColor,
                elevation: 0,
                child: DraggableAppBar(
                  settingsController: widget.settingsController,
                )),
            Expanded(
                child: Card(
                    color: Theme.of(context).cardColor,
                    elevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      children: [
                        WebViewWidget(controller: constants.browserController)
                      ],
                    ))),
          ],
        ),
      )),
    );
  }
}
