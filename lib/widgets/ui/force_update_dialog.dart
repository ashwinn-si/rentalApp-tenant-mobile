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
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (context) => ForceUpdateDialog(
        storeUrl: storeUrl,
      ),
    );
  }

  Future<void> _launchStore() async {
    try {
      final raw = storeUrl.trim();
      if (raw.isEmpty) {
        return;
      }

      final candidate = Uri.tryParse(raw);
      final uri = (candidate != null && candidate.hasScheme)
          ? candidate
          : Uri.tryParse('https://$raw');

      if (uri == null) {
        return;
      }

      final openedInBrowserView = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );

      if (!openedInBrowserView) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Failed to launch store URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
    final messageColor =
        isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const <Color>[Color(0xFF1D1A2B), Color(0xFF171527)]
                : <Color>[Colors.white, Colors.white.withValues(alpha: 0.98)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2550)
                    : AppColors.violet.withOpacity(0.1),
                border: Border.all(
                  color: isDark ? const Color(0xFF3B3267) : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: AppColors.violet,
                size: 40,
              ),
            ),
            Text(
              'Update Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Kindly update the app and come back for the best experience.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: messageColor,
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
