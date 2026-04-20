import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/toast_service.dart';
import '../../../widgets/ui/force_update_dialog.dart';
import '../data/app_version_repository.dart';

const String appStoreUrl =
    'https://play.google.com/store/apps/details?id=com.rentalapp.tenant';

Future<bool> checkForAppUpdate(
  BuildContext context, {
  bool notifyOptionalUpdate = false,
  bool showErrorToast = false,
}) async {
  try {
    const currentBuildNumber = buildNumber;

    final repo = AppVersionRepository();
    final response = await repo.getCurrentVersion();

    if (response.isSuccess && response.data != null) {
      final appVersionData = response.data!;
      final apiBuildNumber = appVersionData.buildNumber ?? 0;
      final isForceUpdate = appVersionData.forceUpdate;

      debugPrint(
        'Version Check: currentBuild=$currentBuildNumber, apiBuild=$apiBuildNumber, forceUpdate=$isForceUpdate',
      );

      final updateNeeded = currentBuildNumber < apiBuildNumber;

      if (updateNeeded && isForceUpdate) {
        debugPrint('Update required. Showing force update dialog.');
        if (context.mounted) {
          await ForceUpdateDialog.show(context, storeUrl: appStoreUrl);
        }
        return true;
      }

      if (updateNeeded && !isForceUpdate) {
        debugPrint('Optional update available (not forced).');
        if (notifyOptionalUpdate && context.mounted) {
          ToastService.showSuccess('New update is available on Play Store');
        }
      }

      return false;
    }

    final errorMsg = response.message ?? 'Failed to check app version';
    debugPrint('Version check failed: $errorMsg');
    if (showErrorToast && context.mounted) {
      ToastService.showError(errorMsg);
    }
    return false;
  } catch (e, st) {
    debugPrint('Version check error: $e');
    debugPrintStack(stackTrace: st);
    if (showErrorToast && context.mounted) {
      ToastService.showError('Version check error. Continuing...');
    }
    return false;
  }
}
