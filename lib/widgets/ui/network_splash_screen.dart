import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/providers/connectivity_provider.dart';
import 'app_button.dart';

class NetworkSplashScreen extends ConsumerWidget {
  const NetworkSplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    return connectivityState.when(
      data: (isOnline) {
        // If online, return empty — app loads normally
        if (isOnline) {
          return const SizedBox.shrink();
        }
        // If offline, show blocking splash
        return const _OfflineScreen();
      },
      error: (err, st) => const SizedBox.shrink(),
      loading: () => const _LoadingScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF111827), Color(0xFF1F2937)]
                : const [AppColors.screenBg, Colors.white],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.violet,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineScreen extends StatelessWidget {
  const _OfflineScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF111827), Color(0xFF1F2937)]
                : const [AppColors.screenBg, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenSize.height * 0.1),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pending.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.wifi_off,
                      size: 48,
                      color: AppColors.pending,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? const Color(0xFFF8FAFC)
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Please connect to WiFi or mobile data to launch the app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.15),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Retry',
                        onPressed: () {
                          // Dialog auto-closes when connectivity changes
                        },
                        fullWidth: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Waiting for connection...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
