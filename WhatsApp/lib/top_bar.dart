import 'package:flutter/material.dart';
import 'package:whatsapp/settings_controller.dart';
import 'package:whatsapp/account.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:window_manager/window_manager.dart';

class AccountManagementDialog extends StatefulWidget {
  final AccountManager accountManager;

  const AccountManagementDialog({
    super.key,
    required this.accountManager,
  });

  @override
  State<AccountManagementDialog> createState() => _AccountManagementDialogState();
}

class _AccountManagementDialogState extends State<AccountManagementDialog> {
  String? _editingAccountId;
  late TextEditingController _renameController;

  @override
  void initState() {
    super.initState();
    _renameController = TextEditingController();
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  void _startRename(WhatsAppAccount account) {
    setState(() {
      _editingAccountId = account.id;
      _renameController.text = account.name;
    });
  }

  void _finishRename() {
    if (_editingAccountId != null) {
      final newName = _renameController.text.trim();
      if (newName.isNotEmpty) {
        widget.accountManager.updateAccountName(_editingAccountId!, newName);
      }
      setState(() {
        _editingAccountId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage Accounts'),
      content: SizedBox(
        width: 400,
        child: ListenableBuilder(
          listenable: widget.accountManager,
          builder: (context, child) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: widget.accountManager.accounts.length,
              itemBuilder: (context, index) {
                final account = widget.accountManager.accounts[index];
                final isCurrent = widget.accountManager.currentAccount?.id == account.id;

                return ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    color: isCurrent ? Theme.of(context).primaryColor : null,
                  ),
                  title: _editingAccountId == account.id
                      ? TextField(
                          controller: _renameController,
                          autofocus: true,
                          onSubmitted: (_) => _finishRename(),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        )
                      : Text(
                          account.name,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                            color: isCurrent ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_editingAccountId != account.id)
                        IconButton(
                          icon: Icon(Icons.edit, size: 18),
                          onPressed: () => _startRename(account),
                          tooltip: 'Rename',
                        ),
                      if (widget.accountManager.accounts.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Account'),
                                content: Text(
                                    'Are you sure you want to delete "${account.name}"? This will remove all data for this account.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close confirmation dialog
                                      Navigator.pop(context); // Close manage accounts dialog
                                      widget.accountManager.removeAccount(account.id);
                                    },
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
                  onTap: _editingAccountId == account.id ? _finishRename : null,
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}

class DraggableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SettingsController settingsController;
  final AccountManager accountManager;

  const DraggableAppBar({
    super.key,
    required this.settingsController,
    required this.accountManager,
  });

  Future<void> toggleTheme(currentBrightness) async {
    if (currentBrightness == Brightness.light) {
      settingsController.updateThemeMode(ThemeMode.dark);
    } else {
      settingsController.updateThemeMode(ThemeMode.light);
    }
    final currentAccount = accountManager.currentAccount;
    if (currentAccount != null) {
      currentAccount.webViewController.reload();
    }
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
                    color: Theme.of(context).hintColor,
                    icon: const Icon(Icons.developer_mode),
                    tooltip: 'Open DevTools',
                    iconSize: 15,
                    onPressed: () {
                      final currentAccount = accountManager.currentAccount;
                      if (currentAccount != null) {
                        (currentAccount.webViewController.platform
                                as WindowsPlatformWebViewController)
                            .openDevTools();
                      }
                    },
                  )),
              SizedBox(
                  height: 20,
                  width: 20,
                  child: IconButton(
                    color: Theme.of(context).hintColor,
                    icon: const Icon(Icons.lightbulb_outlined),
                    tooltip: 'Change Theme',
                    iconSize: 15,
                    onPressed: () async {
                      await toggleTheme(Theme.of(context).brightness);
                    },
                  )),
              SizedBox(
                  height: 20,
                  width: 20,
                  child: IconButton(
                    color: Theme.of(context).hintColor,
                    icon: const Icon(Icons.manage_accounts),
                    tooltip: 'Manage Accounts',
                    iconSize: 15,
                    onPressed: () async {
                      accountManager.setDialogOpen(true);
                      await showDialog(
                        context: context,
                        builder: (context) => AccountManagementDialog(
                          accountManager: accountManager,
                        ),
                      );
                      accountManager.setDialogOpen(false);
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
                    color: Theme.of(context).iconTheme.color,
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
              backgroundColor: Theme.of(context).canvasColor,
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
