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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final titleColor =
            isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
        final messageColor =
            isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;

        return PopScope(
          canPop: false,
          child: Dialog(
            insetAnimationDuration: const Duration(milliseconds: 0),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const <Color>[Color(0xFF1D1A2B), Color(0xFF171527)]
                      : <Color>[
                          Colors.white,
                          Colors.white.withValues(alpha: 0.98)
                        ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
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
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Please connect to the internet to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: messageColor,
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
