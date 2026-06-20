import 'package:flutter/material.dart';
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/manager/account_manager.dart';
import 'package:whatsapp/ui/settings_dialog.dart';
import 'package:window_manager/window_manager.dart';

class DraggableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SettingsController settingsController;
  final AccountManager accountManager;

  const DraggableAppBar({
    super.key,
    required this.settingsController,
    required this.accountManager,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(children: [
            SizedBox(
              height: 25,
              width: 25,
              child: IconButton(
                color: Theme.of(context).hintColor,
                icon: const Icon(Icons.settings),
                tooltip: settingsController.localizations.get('settings'),
                iconSize: 15,
                padding: EdgeInsets.zero,
                onPressed: () async {
                  accountManager.setDialogOpen(true);
                  await showDialog(
                    context: context,
                    builder: (context) => SettingsDialog(
                      settingsController: settingsController,
                      accountManager: accountManager,
                    ),
                  );
                  accountManager.setDialogOpen(false);
                },
              ),
            ),
          ]),
        ),
        DragToMoveArea(
          child: SizedBox(
            height: 25,
            child: Align(
              alignment: AlignmentDirectional.center,
              child: Text("WhatsApp",
                  style: TextStyle(
                    color: Theme.of(context).iconTheme.color,
                  )),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizedBox(
            height: 25,
            width: 200,
            child: WindowCaption(
              backgroundColor: Theme.of(context).canvasColor,
              brightness: Theme.of(context).brightness,
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(25);
}
