import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/providers/connectivity_provider.dart';
import 'app_button.dart';

class InternetCheckDialog extends ConsumerWidget {
  const InternetCheckDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);

    return isOnline.when(
      data: (online) {
        if (online) {
          return const SizedBox.shrink();
        }
        return PopScope(
          canPop: false,
          child: Dialog(
            insetAnimationDuration: const Duration(milliseconds: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 48,
                    color: AppColors.pending,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Please connect to the internet to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'Retry',
                      onPressed: () {
                        // Retry check — dialog will auto-dismiss when online
                      },
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (err, st) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
