import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_tokens.dart';
import 'app_button.dart';

class ForceUpdateDialog extends StatelessWidget {
  const ForceUpdateDialog({
    required this.storeUrl,
    super.key,
  });

  final String storeUrl;

  static Future<void> show(
    BuildContext context, {
    required String storeUrl,
  }) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ForceUpdateDialog(
        storeUrl: storeUrl,
      ),
    );
  }

  Future<void> _launchStore() async {
    try {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Failed to launch store URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.violet.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: AppColors.violet,
                size: 40,
              ),
            ),
            const Text(
              'Update Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Kindly update the app and come back for the best experience.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Update App',
                onPressed: _launchStore,
                backgroundColor: AppColors.violet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
