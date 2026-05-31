import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/constants.dart' as constants;
import 'package:whatsapp/manager/settings_controller.dart';
import 'package:whatsapp/manager/account_manager.dart';

class UpdateChecker {
  static bool _hasChecked = false;

  /// Checks for a remote update. If [force] is true, it runs the check
  /// regardless of the "check on launch" settings toggle.
  static Future<void> checkForUpdates(
    BuildContext context,
    SettingsController settings,
    AccountManager accountManager, {
    bool force = false,
  }) async {
    // Avoid double checking on launch if we already ran the check once.
    if (!force && _hasChecked) return;
    _hasChecked = true;

    // Check if the user has disabled automatic update checking.
    if (!force && !settings.checkForUpdates) {
      debugPrint('Update check on launch is disabled by user setting.');
      return;
    }

    debugPrint(
        'Running update check against remote: ${constants.remoteVersionUrl}');
    final latestVersion = await _fetchLatestVersion();

    if (latestVersion == null) {
      debugPrint('Update check failed or returned empty content.');
      if (force && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not reach the update server. Please check your internet connection.'),
          ),
        );
      }
      return;
    }

    debugPrint(
        'Current Version: ${constants.appVersion}, Remote Version: $latestVersion');

    if (latestVersion != constants.appVersion) {
      if (context.mounted) {
        _showUpdateDialog(context, latestVersion, accountManager);
      }
    } else {
      if (force && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are already running the latest version!'),
          ),
        );
      }
    }
  }

  /// Fetches the latest version string from the remote text file.
  static Future<String?> _fetchLatestVersion() async {
    try {
      final client = HttpClient();
      // Set a reasonable timeout for the connection
      client.connectionTimeout = const Duration(seconds: 5);

      final request =
          await client.getUrl(Uri.parse(constants.remoteVersionUrl));
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final rawBody = await response.transform(utf8.decoder).join();
        return rawBody.trim();
      } else {
        debugPrint(
            'HTTP error response fetching version: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception while checking for updates: $e');
    }
    return null;
  }

  /// Displays the update notification dialog.
  static void _showUpdateDialog(
    BuildContext context,
    String latestVersion,
    AccountManager accountManager,
  ) async {
    accountManager.setDialogOpen(true);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Icon(
                Icons.system_update_alt_rounded,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Update Available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A new version of WhatsApp Portable is available.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          constants.appVersion,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    Column(
                      children: [
                        Text(
                          'LATEST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latestVersion,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Updating is highly recommended to receive the latest security improvements, fixes, and new features.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Later',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                launchUrl(Uri.parse(constants.repoReleasesUrl));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Download Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    accountManager.setDialogOpen(false);
  }
}
