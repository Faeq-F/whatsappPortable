import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'constants.dart' as constants;
import 'package:whatsapp/settings_controller.dart';

class WhatsAppAccount {
  final String id;
  String name;
  final String dataDirectory;
  WebViewController? _webViewController;
  bool isActive;
  bool _webViewSetupDone = false;

  WhatsAppAccount({
    required this.id,
    required this.name,
    required this.dataDirectory,
    this.isActive = false,
  });

  WebViewController get webViewController {
    if (_webViewController == null) {
      throw StateError('webViewController accessed before initialization for account $id');
    }
    return _webViewController!;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dataDirectory': dataDirectory,
      'isActive': isActive,
    };
  }

  factory WhatsAppAccount.fromJson(Map<String, dynamic> json) {
    return WhatsAppAccount(
      id: json['id'],
      name: json['name'],
      dataDirectory: json['dataDirectory'],
      isActive: json['isActive'] ?? false,
    );
  }

  void initializeWebViewController() {
    if (_webViewController != null) {
      debugPrint('webViewController already initialized for account $id, skipping');
      return;
    }
    final normalizedPath = dataDirectory;
    debugPrint("Initializing WebViewController with userDataFolder: $normalizedPath");
    final params = WindowsPlatformWebViewControllerCreationParams(
      userDataFolder: normalizedPath,
    );
    _webViewController = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        var req = request.platform as WinWebViewPermissionRequest;
        // only allow "notification", deny all others
        if (req.kind == WinWebViewPermissionResourceType.notification) {
          req.grant();
        } else {
          req.deny();
        }
        debugPrint("permission: ${req.kind} , ${req.url}");
      },
    );
    debugPrint('webViewController initialized for account $id');
  }

  Future<void> setupWebViewDataDirectory() async {
    final directory = Directory(dataDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    debugPrint("Account data directory created: $dataDirectory");
  }

  void setupWebView(SettingsController settingsController) {
    if (_webViewSetupDone) {
      debugPrint('webView already set up for account $id, skipping');
      return;
    }
    _webViewController!.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (request) {
        var launch = NavigationDecision.navigate;
        if (!request.url.contains("whatsapp")) {
          launchUrl(Uri.parse(request.url));
          launch = NavigationDecision.prevent;
        }
        return launch;
      },
      onPageFinished: (url) {
        final brightness = settingsController.themeMode == ThemeMode.system
            ? WidgetsBinding.instance.platformDispatcher.platformBrightness
            : (settingsController.themeMode == ThemeMode.light
                ? Brightness.light
                : Brightness.dark);

        if (brightness == Brightness.light) {
          _webViewController!.runJavaScript(constants.lightModeJS);
        } else {
          _webViewController!.runJavaScript(constants.darkModeJS);
        }
      },
      onWebResourceError: (error) =>
          debugPrint("onWebResourceError: ${error.description}"),
    ));
    _webViewController!.loadRequest(Uri.parse("https://web.whatsapp.com/"));
    _webViewSetupDone = true;
    debugPrint('webView set up for account $id');
  }
}

class AccountManager with ChangeNotifier {
  final SettingsController settingsController;

  AccountManager({required this.settingsController});

  List<WhatsAppAccount> _accounts = [];
  WhatsAppAccount? _currentAccount;
  bool _isDialogOpen = false;

  List<WhatsAppAccount> get accounts => _accounts;
  WhatsAppAccount? get currentAccount => _currentAccount;
  bool get isDialogOpen => _isDialogOpen;

  void setDialogOpen(bool isOpen) {
    _isDialogOpen = isOpen;
    notifyListeners();
  }

  Future<File> get _accountsFile async {
    final path = Directory.current.path;
    return File('$path/accounts.json');
  }

  Future<void> loadAccounts() async {
    final file = await _accountsFile;
    if (!await file.exists()) {
      await _createDefaultAccount();
      return;
    }

    try {
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        await _createDefaultAccount();
        return;
      }

      final accountsData = jsonDecode(contents) as List<dynamic>;
      _accounts = accountsData
          .map((accountData) => WhatsAppAccount.fromJson(accountData))
          .toList();

      // Initialize webview controllers for all accounts
      for (var account in _accounts) {
        account.initializeWebViewController();
        await account.setupWebViewDataDirectory();
        account.setupWebView(settingsController);
      }

      // Set first account as current if none is active
      if (_currentAccount == null && _accounts.isNotEmpty) {
        _currentAccount = _accounts.first;
        _currentAccount!.isActive = true;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      await _createDefaultAccount();
    }
  }

  Future<void> _createDefaultAccount() async {
    final defaultAccount = WhatsAppAccount(
      id: 'account_1',
      name: 'Account 1',
      dataDirectory: '${Directory.current.path}\\data\\account_1',
    );

    defaultAccount.initializeWebViewController();
    await defaultAccount.setupWebViewDataDirectory();
    defaultAccount.setupWebView(settingsController);

    _accounts = [defaultAccount];
    _currentAccount = defaultAccount;
    defaultAccount.isActive = true;

    await saveAccounts();
    notifyListeners();
  }

  Future<void> saveAccounts() async {
    final file = await _accountsFile;
    final accountsData = _accounts.map((account) => account.toJson()).toList();
    await file.writeAsString(jsonEncode(accountsData));
  }

  Future<void> addAccount({String? name}) async {
    final accountId = 'account_${DateTime.now().millisecondsSinceEpoch}';
    final accountName = name ?? 'Account ${_accounts.length + 1}';
    final dataDirectory = '${Directory.current.path}\\data\\$accountId';

    final newAccount = WhatsAppAccount(
      id: accountId,
      name: accountName,
      dataDirectory: dataDirectory,
    );

    newAccount.initializeWebViewController();
    await newAccount.setupWebViewDataDirectory();
    newAccount.setupWebView(settingsController);

    _accounts.add(newAccount);
    await saveAccounts();
    notifyListeners();
  }

  Future<void> removeAccount(String accountId) async {
    if (_accounts.length <= 1) {
      debugPrint('Cannot remove the last account');
      return;
    }

    final accountToRemove =
        _accounts.firstWhere((account) => account.id == accountId);

    // 1. Remove from state and notify listeners FIRST.
    // This removes the WebViewWidget from the tree, triggering its deactivate()
    // method cleanly while the controller is still alive.
    _accounts.removeWhere((account) => account.id == accountId);

    if (_currentAccount?.id == accountId) {
      _currentAccount = _accounts.first;
      _currentAccount!.isActive = true;
    }

    notifyListeners();

    // Give Flutter a tiny moment to complete the unmount and deactivate()
    await Future.delayed(const Duration(milliseconds: 100));

    // 2. Dispose webview controller
    try {
      final platformController = accountToRemove.webViewController.platform as WindowsPlatformWebViewController;
      await platformController.controller.dispose();
    } catch (e) {
      debugPrint('Error disposing webview controller: $e');
    }

    // 3. Give Windows a moment to fully release the file handles
    await Future.delayed(const Duration(milliseconds: 500));

    // 4. Clean up data directory
    try {
      final directory = Directory(accountToRemove.dataDirectory);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting account data directory: $e');
    }

    await saveAccounts();
  }

  Future<void> switchAccount(String accountId) async {
    if (_currentAccount?.id == accountId) return;

    final newAccount =
        _accounts.firstWhere((account) => account.id == accountId);

    if (_currentAccount != null) {
      _currentAccount!.isActive = false;
    }

    _currentAccount = newAccount;
    _currentAccount!.isActive = true;

    await saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccountName(String accountId, String newName) async {
    final account = _accounts.firstWhere((account) => account.id == accountId);
    account.name = newName;
    await saveAccounts();
    notifyListeners();
  }
}
