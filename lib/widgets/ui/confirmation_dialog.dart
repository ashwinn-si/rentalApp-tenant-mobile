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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isDangerous)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.pending.withOpacity(0.1),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
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
                      side: const BorderSide(
                        color: AppColors.violet,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(
                      cancelLabel,
                      style: const TextStyle(
                        color: AppColors.violet,
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
                    backgroundColor:
                        isDangerous ? AppColors.pending : AppColors.violet,
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
