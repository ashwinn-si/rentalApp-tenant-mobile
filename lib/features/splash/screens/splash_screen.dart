import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../app_version/data/app_version_repository.dart';
import '../../../widgets/ui/force_update_dialog.dart';

const String appStoreUrl =
    'https://play.google.com/store/apps/details?id=com.rentalapp.tenant';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _navigateToHome();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      final repo = AppVersionRepository();
      final response = await repo.getCurrentVersion();

      if (response.isSuccess && response.data != null) {
        final appVersionData = response.data!;
        final apiBuildNumber = appVersionData.buildNumber ?? 0;
        final isForceUpdate = appVersionData.forceUpdate;

        debugPrint(
          'Version Check: currentBuild=$currentBuildNumber, apiBuild=$apiBuildNumber, forceUpdate=$isForceUpdate',
        );

        // Check if update is needed: current build < api build
        final updateNeeded = currentBuildNumber < apiBuildNumber;

        // Show update dialog if update needed AND force update is true
        if (updateNeeded && isForceUpdate) {
          debugPrint('Update required. Showing force update dialog.');
          if (mounted) {
            await ForceUpdateDialog.show(context, storeUrl: appStoreUrl);
          }
          return; // do not navigate
        }

        // If update available but not forced, just log it
        if (updateNeeded && !isForceUpdate) {
          debugPrint('Optional update available (not forced).');
        }
      } else {
        // API call failed, show error toast but allow navigation
        final errorMsg = response.message ?? 'Failed to check app version';
        debugPrint('Version check failed: $errorMsg');
        if (mounted) {
          ToastService.showError(errorMsg);
        }
      }
    } catch (e, st) {
      debugPrint('Version check error: $e');
      debugPrintStack(stackTrace: st);
      // Show error toast but allow navigation
      if (mounted) {
        ToastService.showError('Version check error. Continuing...');
      }
    }

    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.violet, Color(0xFF6D28D9)],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Tenant Portal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Manage your rentals effortlessly',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
