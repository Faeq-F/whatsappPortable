import 'package:flutter/material.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:io';
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/model/account.dart';

class AccountManager with ChangeNotifier {
  final SettingsController settingsController;

  AccountManager({required this.settingsController});

  List<WhatsAppAccount> _accounts = [];
  WhatsAppAccount? _currentAccount;
  int _openDialogsCount = 0;
  bool _hasAnyNotification = false;

  static const String _normalIconPath = 'images/icon.ico';
  static const String _notificationIconPath = 'images/icon_notification.ico';

  List<WhatsAppAccount> get accounts => _accounts;
  WhatsAppAccount? get currentAccount => _currentAccount;
  bool get isDialogOpen => _openDialogsCount > 0;

  void setDialogOpen(bool isOpen) {
    if (isOpen) {
      _openDialogsCount++;
    } else {
      _openDialogsCount = (_openDialogsCount - 1).clamp(0, 99);
    }
    notifyListeners();
  }

  WhatsAppAccount _findAccount(String id) =>
      _accounts.firstWhere((account) => account.id == id);

  Future<void> loadAccounts() async {
    final settings = await settingsController.readSettings();
    final accountsData = settings['accounts'] as List<dynamic>?;

    if (accountsData == null || accountsData.isEmpty) {
      await _createDefaultAccount();
      final activeIds = _accounts.map((a) => a.id).toList();
      await _cleanupUnusedProfiles(activeIds);
      return;
    }

    try {
      final loadedAccounts = accountsData
          .map((accountData) => WhatsAppAccount.fromJson(accountData))
          .toList();

      final activeIds = loadedAccounts.map((a) => a.id).toList();
      await _cleanupUnusedProfiles(activeIds);

      for (var account in loadedAccounts) {
        account.initializeWebViewController();
        await account.ensureSharedDataDirectory();
        account.setupWebView(
          settingsController,
          onNotificationChanged: _onNotificationChanged,
        );
      }

      _accounts = loadedAccounts;

      if (_currentAccount == null && _accounts.isNotEmpty) {
        _currentAccount = _accounts.firstWhere(
          (a) => a.isActive,
          orElse: () => _accounts.first,
        );
        _currentAccount!.isActive = true;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      await _createDefaultAccount();
    }
  }

  Future<void> _cleanupUnusedProfiles(List<String> activeIds) async {
    try {
      final ebWebViewDir = Directory(
          '${WhatsAppAccount.sharedDataDirectory}\\EBWebView');
      if (!await ebWebViewDir.exists()) return;

      final List<FileSystemEntity> entities = await ebWebViewDir.list().toList();
      for (final entity in entities) {
        if (entity is Directory) {
          final String dirName = entity.path.split(Platform.pathSeparator).last;
          if (dirName.startsWith('WV2Profile_')) {
            final profileId = dirName.substring('WV2Profile_'.length);
            if (!activeIds.contains(profileId)) {
              debugPrint('Found unused profile directory: $dirName. Deleting...');
              try {
                await entity.delete(recursive: true);
                debugPrint('Successfully deleted unused profile directory: $dirName');
              } catch (e) {
                debugPrint('Failed to delete unused profile directory $dirName: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error during unused profiles cleanup: $e');
    }
  }

  Future<void> _createDefaultAccount() async {
    final defaultAccount = WhatsAppAccount(
      id: WhatsAppAccount.generateId(),
      name: 'Account 1',
    );

    defaultAccount.initializeWebViewController();
    await defaultAccount.ensureSharedDataDirectory();
    defaultAccount.setupWebView(
      settingsController,
      onNotificationChanged: _onNotificationChanged,
    );

    _accounts = [defaultAccount];
    _currentAccount = defaultAccount;
    defaultAccount.isActive = true;

    await saveAccounts();
    notifyListeners();
  }

  Future<void> saveAccounts() async {
    final settings = await settingsController.readSettings();
    settings['accounts'] = _accounts.map((a) => a.toJson()).toList();
    await settingsController.writeSettings(settings);
  }

  Future<void> addAccount({String? name}) async {
    final accountId = WhatsAppAccount.generateId();
    final accountName = name ?? 'Account ${_accounts.length + 1}';

    final newAccount = WhatsAppAccount(
      id: accountId,
      name: accountName,
    );

    newAccount.initializeWebViewController();
    await newAccount.ensureSharedDataDirectory();
    newAccount.setupWebView(
      settingsController,
      onNotificationChanged: _onNotificationChanged,
    );

    _accounts.add(newAccount);
    await saveAccounts();
    notifyListeners();
  }

  Future<void> removeAccount(String accountId) async {
    if (_accounts.length <= 1) {
      debugPrint('Cannot remove the last account');
      return;
    }

    final accountToRemove = _findAccount(accountId);

    _accounts.removeWhere((account) => account.id == accountId);

    if (_currentAccount?.id == accountId) {
      _currentAccount = _accounts.first;
      _currentAccount!.isActive = true;
    }

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final platformController = accountToRemove.webViewController.platform
          as WindowsPlatformWebViewController;
      await platformController.controller.dispose();
    } catch (e) {
      debugPrint('Error disposing webview controller: $e');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final profileDir = Directory(
          '${WhatsAppAccount.sharedDataDirectory}\\EBWebView\\WV2Profile_$accountId');
      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
        debugPrint('Deleted profile directory for account $accountId');
      }
    } catch (e) {
      debugPrint('Error deleting profile directory for account $accountId: $e');
    }

    await saveAccounts();
  }

  Future<void> switchAccount(String accountId) async {
    if (_currentAccount?.id == accountId) return;

    final newAccount = _findAccount(accountId);

    if (_currentAccount != null) {
      _currentAccount!.isActive = false;
    }

    _currentAccount = newAccount;
    _currentAccount!.isActive = true;

    await saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccountName(String accountId, String newName) async {
    final account = _findAccount(accountId);
    account.name = newName;
    await saveAccounts();
    notifyListeners();
  }

  /// Callback invoked by each account's WebView when notification state changes.
  void _onNotificationChanged(String accountId, bool hasNotification) {
    final anyHasNotification =
        _accounts.any((account) => account.hasNotification);

    if (anyHasNotification != _hasAnyNotification) {
      _hasAnyNotification = anyHasNotification;
      _updateTrayIcon();
    }
  }

  /// Updates the system tray icon based on the current notification state.
  Future<void> _updateTrayIcon() async {
    final iconPath =
        _hasAnyNotification ? _notificationIconPath : _normalIconPath;
    try {
      await trayManager.setIcon(iconPath);
      debugPrint('Tray icon updated: $iconPath');
    } catch (e) {
      debugPrint('Error updating tray icon: $e');
    }
  }
}
