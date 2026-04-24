import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/notification_permission_service.dart';

class EnableNotificationsScreen extends ConsumerStatefulWidget {
  const EnableNotificationsScreen({super.key});

  @override
  ConsumerState<EnableNotificationsScreen> createState() =>
      _EnableNotificationsScreenState();
}

class _EnableNotificationsScreenState
    extends ConsumerState<EnableNotificationsScreen> {
  bool _dialogShown = false;
  bool _isBusy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dialogShown) return;
    _dialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showBlockingDialog();
    });
  }

  Future<void> _showBlockingDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Enable notifications',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Kindly enable notifications so you can receive important alerts and '
            'see them on your lock screen.',
          ),
          actions: [
            TextButton(
              onPressed: _isBusy
                  ? null
                  : () async {
                      Navigator.of(ctx).pop();
                      await _onEnablePressed();
                    },
              child: const Text('Enable'),
            ),
            TextButton(
              onPressed: _isBusy
                  ? null
                  : () async {
                      await NotificationPermissionService.openSettings();
                    },
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onEnablePressed() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final ok = await NotificationPermissionService.request();
      if (!mounted) return;
      if (ok) {
        // Router redirect will move user into the app automatically.
        context.go('/splash');
        return;
      }
      await _showBlockingDialog();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.violet, Color(0xFF6D28D9)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 44,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Notifications required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Please enable notifications to continue. This helps ensure '
                  'rent reminders, alerts, and updates show on your lock screen.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isBusy ? null : _onEnablePressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.violet,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(_isBusy ? 'Checking…' : 'Enable notifications'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isBusy
                        ? null
                        : () => NotificationPermissionService.openSettings(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Open settings'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

