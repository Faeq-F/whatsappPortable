import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/manager/localization.dart';
import 'package:whatsapp/model/account.dart';
import 'package:whatsapp/manager/account_manager.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:whatsapp/manager/update_checker.dart';

class SettingsDialog extends StatefulWidget {
  final SettingsController settingsController;
  final AccountManager accountManager;

  const SettingsDialog({
    super.key,
    required this.settingsController,
    required this.accountManager,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final loc = widget.settingsController.localizations;
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (context, child) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      icon: Icons.color_lens_outlined, title: loc.get('theme')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<ThemeMode>(
                      value: widget.settingsController.themeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(loc.get('system')),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(loc.get('light')),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(loc.get('dark')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        final navigator = Navigator.of(context);
                        unawaited(widget.settingsController
                            .updateThemeMode(value)
                            .then((_) {
                          if (!mounted) return;
                          final currentAccount =
                              widget.accountManager.currentAccount;
                          if (currentAccount != null) {
                            currentAccount.webViewController.reload();
                          }
                          navigator.pop();
                        }));
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.get('match_cohesive'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _SectionHeader(
                      icon: Icons.language, title: loc.get('language')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: widget.settingsController.language,
                            items: AppLanguages.list.map((lang) {
                              return DropdownMenuItem<String>(
                                value: lang['code'],
                                child: Text(lang['name']!),
                              );
                            }).toList(),
                            onChanged: widget.settingsController.isTranslating
                                ? null
                                : (value) async {
                                    if (value == null) return;
                                    await widget.settingsController.updateLanguage(value);
                                    // Notify webview of new language target
                                    final currentAccount = widget.accountManager.currentAccount;
                                    if (currentAccount != null) {
                                      await currentAccount.updateWebviewLanguage(value);
                                    }
                                  },
                          ),
                        ),
                        if (widget.settingsController.isTranslating)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  _SectionHeader(
                      icon: Icons.manage_accounts, title: loc.get('manage_accounts')),
                  SizedBox(
                    height: 200,
                    child: ListenableBuilder(
                      listenable: widget.accountManager,
                      builder: (context, child) {
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: widget.accountManager.accounts.length,
                          itemBuilder: (context, index) {
                            final account = widget.accountManager.accounts[index];
                            final isCurrent =
                                widget.accountManager.currentAccount?.id ==
                                    account.id;
                            return _AccountTile(
                              account: account,
                              isCurrent: isCurrent,
                              accountManager: widget.accountManager,
                              localizations: loc,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(loc.get('add_account')),
                        onPressed: () {
                          widget.accountManager.addAccount();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: widget.settingsController.alwaysShowTabBar,
                          onChanged: (value) {
                            if (value != null) {
                              widget.settingsController
                                  .updateAlwaysShowTabBar(value);
                            }
                          },
                        ),
                        Text(loc.get('always_show_tab_bar')),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _SectionHeader(icon: Icons.update, title: loc.get('updates')),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: widget.settingsController.checkForUpdates,
                          onChanged: (value) {
                            if (value != null) {
                              widget.settingsController
                                  .updateCheckForUpdates(value);
                            }
                          },
                        ),
                        Expanded(child: Text(loc.get('check_updates_launch'))),
                        TextButton(
                          onPressed: () {
                            UpdateChecker.checkForUpdates(
                              context,
                              widget.settingsController,
                              widget.accountManager,
                              force: true,
                            );
                          },
                          child: Text(loc.get('check_now')),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _SectionHeader(
                      icon: Icons.developer_mode, title: loc.get('devtools')),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(loc.get('debug_active_tab')),
                        onPressed: () {
                          final currentAccount =
                              widget.accountManager.currentAccount;
                          if (currentAccount != null) {
                            (currentAccount.webViewController.platform
                                    as WindowsPlatformWebViewController)
                                .openDevTools();
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).hintColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatefulWidget {
  final WhatsAppAccount account;
  final bool isCurrent;
  final AccountManager accountManager;
  final AppLocalizations localizations;

  const _AccountTile({
    required this.account,
    required this.isCurrent,
    required this.accountManager,
    required this.localizations,
  });

  @override
  State<_AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<_AccountTile> {
  bool _editing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.account.name);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _editing) {
      _finishRename();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localizations;
    return ListTile(
      leading: Icon(
        Icons.account_circle,
        color: widget.isCurrent ? Theme.of(context).primaryColor : null,
      ),
      title: _editing
          ? TextField(
              controller: _controller,
              autofocus: true,
              focusNode: _focusNode,
              decoration: const InputDecoration(border: InputBorder.none),
            )
          : Text(
              widget.account.name,
              style: TextStyle(
                fontWeight:
                    widget.isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isCurrent)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.check, size: 16, color: Colors.green),
            ),
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => setState(() => _editing = true),
              tooltip: loc.get('rename'),
            ),
          if (widget.accountManager.accounts.length > 1)
            IconButton(
              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(loc.get('delete_account_title')),
                    content: Text(
                      loc.get('delete_account_confirm', args: {'name': widget.account.name}),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.get('cancel')),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.accountManager
                              .removeAccount(widget.account.id);
                        },
                        child: Text(loc.get('delete'),
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              tooltip: loc.get('delete'),
            ),
        ],
      ),
      onTap: _editing ? _finishRename : null,
    );
  }

  void _finishRename() {
    final newName = _controller.text.trim();
    if (newName.isNotEmpty) {
      widget.accountManager.updateAccountName(widget.account.id, newName);
    }
    setState(() => _editing = false);
  }
}
