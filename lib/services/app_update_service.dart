import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Google Play [in-app updates](https://developer.android.com/guide/playcore/in-app-updates)
/// (Android only). iOS does not support this API; updates go through the App Store.
class AppUpdateService {
  AppUpdateService._();

  static StreamSubscription<InstallStatus>? _installSubscription;

  /// Call after the first frame when a [Scaffold] with [ScaffoldMessenger] is available.
  static Future<void> checkAndroidInAppUpdate(BuildContext context) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result != AppUpdateResult.success) {
          return;
        }

        await _installSubscription?.cancel();
        _installSubscription = InAppUpdate.installUpdateListener.listen(
          (InstallStatus status) async {
            if (status != InstallStatus.downloaded) return;
            await _installSubscription?.cancel();
            _installSubscription = null;

            if (!context.mounted) return;
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              SnackBar(
                content: const Text(
                  'An update has been downloaded. Restart to finish installing.',
                ),
                action: SnackBarAction(
                  label: 'Restart',
                  onPressed: () {
                    InAppUpdate.completeFlexibleUpdate();
                  },
                ),
                duration: const Duration(minutes: 5),
              ),
            );
          },
        );
        return;
      }

      if (info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('In-app update skipped: $e\n$st');
      }
    }
  }

  static Future<void> cancelInstallListener() async {
    await _installSubscription?.cancel();
    _installSubscription = null;
  }
}
