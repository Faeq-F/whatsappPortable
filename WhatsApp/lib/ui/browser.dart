import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/ui/top_bar.dart';
import 'package:whatsapp/manager/account_manager.dart';
import 'package:whatsapp/manager/update_checker.dart';
import 'package:window_manager/window_manager.dart';

class Browser extends StatefulWidget {
  final SettingsController settingsController;
  const Browser({super.key, required this.settingsController});

  @override
  State<Browser> createState() => _Browser();
}

class _Browser extends State<Browser> with WindowListener {
  late AccountManager _accountManager;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _accountManager =
        AccountManager(settingsController: widget.settingsController);
    _loadAccounts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.checkForUpdates(context, widget.settingsController, _accountManager);
    });
  }

  Future<void> _loadAccounts() async {
    await _accountManager.loadAccounts();
    final currentAccount = _accountManager.currentAccount;
    if (currentAccount != null) {
      _selectedIndex = _accountManager.accounts.indexWhere(
        (account) => account.id == currentAccount.id,
      );
      if (_selectedIndex < 0) _selectedIndex = 0;
    }
    _updateWebViewVisibility();
  }

  Future<void> _switchAccount(String accountId) async {
    await _accountManager.switchAccount(accountId);
    final currentAccount = _accountManager.currentAccount;
    if (currentAccount != null) {
      setState(() {
        _selectedIndex = _accountManager.accounts.indexWhere(
          (account) => account.id == currentAccount.id,
        );
        if (_selectedIndex < 0) _selectedIndex = 0;
      });
    }
    _updateWebViewVisibility();
  }

  void _updateWebViewVisibility() {
    for (int i = 0; i < _accountManager.accounts.length; i++) {
      final account = _accountManager.accounts[i];
      final shouldBeVisible =
          (i == _selectedIndex) && !_accountManager.isDialogOpen;
      final platformController = account.webViewController.platform
          as WindowsPlatformWebViewController;
      platformController.controller.setVisibility(shouldBeVisible);
    }
  }

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
  Widget build(BuildContext context) {
    return Column(
      children: [
        DraggableAppBar(
          settingsController: widget.settingsController,
          accountManager: _accountManager,
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _accountManager,
            builder: (context, child) {
              final accountCount = _accountManager.accounts.length;

              if (accountCount == 0) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No accounts. Add one to get started.'),
                  ],
                );
              }

              if (_selectedIndex >= accountCount) {
                _selectedIndex = accountCount - 1;
              }

              final tabKey = ValueKey(
                '${_accountManager.accounts.length}_${_accountManager.currentAccount?.id}',
              );

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateWebViewVisibility();
              });

              return Column(
                children: [
                  if (widget.settingsController.alwaysShowTabBar ||
                      accountCount > 1)
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DefaultTabController(
                              key: tabKey,
                              length: accountCount,
                              initialIndex: _selectedIndex,
                              child: Builder(
                                builder: (context) {
                                  return TabBar(
                                    controller:
                                        DefaultTabController.of(context),
                                    isScrollable: true,
                                    onTap: (index) {
                                      if (index >= 0 &&
                                          index <
                                              _accountManager.accounts.length) {
                                        final account =
                                            _accountManager.accounts[index];
                                        if (account.id !=
                                            _accountManager
                                                .currentAccount?.id) {
                                          _switchAccount(account.id);
                                        }
                                      }
                                    },
                                    tabs:
                                        _accountManager.accounts.map((account) {
                                      return Tab(text: account.name);
                                    }).toList(),
                                    labelColor: Theme.of(context).primaryColor,
                                    unselectedLabelColor: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    indicatorColor:
                                        Theme.of(context).primaryColor,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Card(
                      color: Theme.of(context).cardColor,
                      elevation: 0,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: _accountManager.accounts.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                              children: _accountManager.accounts.map((account) {
                                return Positioned.fill(
                                  child: WebViewWidget(
                                    key: ValueKey(account.id),
                                    controller: account.webViewController,
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
