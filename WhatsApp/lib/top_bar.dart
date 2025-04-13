import 'package:flutter/material.dart';
import 'package:whatsapp/settings_controller.dart';
import 'package:window_manager/window_manager.dart';
import 'constants.dart' as constants;

class DraggableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SettingsController settingsController;

  const DraggableAppBar({
    super.key,
    required this.settingsController,
  });

  Future<void> toggleTheme() async {
    settingsController.updateThemeMode();
    constants.browserController.reload();
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
                    color: (Theme.of(context).brightness == Brightness.light
                        ? Colors.black54
                        : Colors.white60),
                    icon: const Icon(Icons.developer_mode),
                    tooltip: 'Open DevTools',
                    iconSize: 15,
                    onPressed: () {
                      constants.browserController.openDevTools();
                    },
                  )),
              SizedBox(
                  height: 20,
                  width: 20,
                  child: IconButton(
                    color: (Theme.of(context).brightness == Brightness.light
                        ? Colors.black54
                        : Colors.white60),
                    icon: const Icon(Icons.lightbulb_outlined),
                    tooltip: 'Change Theme',
                    iconSize: 15,
                    onPressed: () async {
                      await toggleTheme();
                    },
                  )),
            ])),
        //App bar title
        DragToMoveArea(
          child: SizedBox(
            height: 20,
            child: Align(
              alignment: AlignmentDirectional.center,
              child: Text("WhatsApp",
                  style: TextStyle(
                    color: (Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
                  )),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizedBox(
            height: 20,
            width: 200,
            child: WindowCaption(
              backgroundColor: (Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black),
              brightness: Theme.of(context).brightness,
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(20);
}
