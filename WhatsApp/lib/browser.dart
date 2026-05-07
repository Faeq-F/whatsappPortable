import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatsapp/settings_controller.dart';
import 'package:whatsapp/top_bar.dart';
import 'package:whatsapp/account.dart';
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
    _accountManager = AccountManager(settingsController: widget.settingsController);
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    await _accountManager.loadAccounts();
    // Set initial selected index
    final currentAccount = _accountManager.currentAccount;
    if (currentAccount != null) {
      _selectedIndex = _accountManager.accounts.indexWhere(
        (account) => account.id == currentAccount.id,
      );
      if (_selectedIndex < 0) _selectedIndex = 0;
    }
  }

  Future<void> _switchAccount(String accountId) async {
    await _accountManager.switchAccount(accountId);
    // Update selected index
    final currentAccount = _accountManager.currentAccount;
    if (currentAccount != null) {
      setState(() {
        _selectedIndex = _accountManager.accounts.indexWhere(
          (account) => account.id == currentAccount.id,
        );
        if (_selectedIndex < 0) _selectedIndex = 0;
      });
    }
  }

  Future<void> _addAccount() async {
    await _accountManager.addAccount();
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No accounts. Add one to get started.'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addAccount,
                      tooltip: 'Add Account',
                    ),
                  ],
                );
              }

              // Use a key to force TabBar recreation when accounts change
              final tabKey = ValueKey(
                '${_accountManager.accounts.length}_${_accountManager.currentAccount?.id}',
              );

              return Column(
                children: [
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
                                  controller: DefaultTabController.of(context),
                                  isScrollable: true,
                                  onTap: (index) {
                                    if (index >= 0 && index < _accountManager.accounts.length) {
                                      final account = _accountManager.accounts[index];
                                      if (account.id != _accountManager.currentAccount?.id) {
                                        _switchAccount(account.id);
                                      }
                                    }
                                  },
                                  tabs: _accountManager.accounts.map((account) {
                                    return Tab(text: account.name);
                                  }).toList(),
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  indicatorColor: Theme.of(context).primaryColor,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                );
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addAccount,
                          tooltip: 'Add Account',
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
                          ? Center(child: CircularProgressIndicator())
                          : Stack(
                              children: _accountManager.accounts.asMap().entries.map((entry) {
                                final index = entry.key;
                                final account = entry.value;
                                final isVisible = (index == _selectedIndex) && !_accountManager.isDialogOpen;
                                return Positioned(
                                  left: isVisible ? 0 : -10000,
                                  top: isVisible ? 0 : -10000,
                                  right: isVisible ? 0 : null,
                                  bottom: isVisible ? 0 : null,
                                  width: isVisible ? null : 1,
                                  height: isVisible ? null : 1,
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
