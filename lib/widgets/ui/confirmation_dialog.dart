import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import 'app_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.isDangerous = false,
    this.cancelLabel = 'Cancel',
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final bool isDangerous;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDangerous = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.62),
          builder: (context) => ConfirmationDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            isDangerous: isDangerous,
            onConfirm: () {
              Navigator.pop(context, true);
            },
          ),
        ) ??
        false;
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
            if (isDangerous)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3D2F1C)
                      : AppColors.pending.withOpacity(0.1),
                  border: Border.all(
                    color:
                        isDark ? const Color(0xFF5C4729) : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.pending,
                  size: 32,
                ),
              ),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: messageColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            isDark ? const Color(0xFF9F8CFF) : AppColors.violet,
                        width: 2,
                      ),
                      backgroundColor:
                          isDark ? const Color(0xFF221D35) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(
                      cancelLabel,
                      style: TextStyle(
                        color:
                            isDark ? const Color(0xFFC5B8FF) : AppColors.violet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    onPressed: onConfirm,
                    backgroundColor: isDangerous
                        ? const Color(0xFFDC2626)
                        : AppColors.violet,
                    useSolidBackground: isDangerous,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
