import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/confirmation_dialog.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showChangePasswordBottomSheet(BuildContext context) async {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _isChangingPassword = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      enabled: !_isChangingPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      enabled: !_isChangingPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      enabled: !_isChangingPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isChangingPassword
                            ? null
                            : () async {
                                if (_currentPasswordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Current password is required'),
                                    ),
                                  );
                                  return;
                                }

                                if (_newPasswordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('New password is required'),
                                    ),
                                  );
                                  return;
                                }

                                if (_newPasswordController.text !=
                                    _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'New password and confirm password do not match',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isChangingPassword = true;
                                });

                                try {
                                  await ref.read(
                                    changePasswordProvider(
                                      ChangePasswordParams(
                                        currentPassword:
                                            _currentPasswordController.text,
                                        newPassword: _newPasswordController.text,
                                      ),
                                    ).future,
                                  );

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password changed successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceFirst('Exception: ', ''),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isChangingPassword = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          _isChangingPassword ? 'Changing...' : 'Change Password',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required String label,
    required String? value,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayValue = (value == null || value.trim().isEmpty) ? '-' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? const Color(0xFFB8BED3)
                  : AppColors.textSecondary.withValues(alpha: 0.84),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary,
            ),
          ),
          if (!isLast) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.violet.withValues(alpha: 0.08),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(profileProvider),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: ScreenBackground(
        child: asyncProfile.when(
          loading: () => const AppLoader(),
          error: (_, __) => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: StateCard(
                message: 'Unable to load profile',
                variant: StateCardVariant.error),
          ),
          data: (profile) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              StaggeredListView(
                children: <Widget>[
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Profile Details',
                          style: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _detailRow(
                          context,
                          label: 'Name',
                          value: profile.name,
                        ),
                        _detailRow(
                          context,
                          label: 'Email',
                          value: profile.email,
                        ),
                        _detailRow(
                          context,
                          label: 'Phone',
                          value: profile.phone,
                        ),
                        _detailRow(
                          context,
                          label: 'Alternate Phone',
                          value: profile.alternatePhone,
                        ),
                        _detailRow(
                          context,
                          label: 'Aadhaar',
                          value: profile.aadhaarMasked,
                        ),
                        _detailRow(
                          context,
                          label: 'PAN',
                          value: profile.panMasked,
                        ),
                        _detailRow(
                          context,
                          label: 'Emergency Contact Name',
                          value: profile.emergencyName,
                        ),
                        _detailRow(
                          context,
                          label: 'Emergency Contact Relation',
                          value: profile.emergencyRelation,
                        ),
                        _detailRow(
                          context,
                          label: 'Emergency Phone',
                          value: profile.emergencyPhone,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: AppButton(
                      label: 'Change Password',
                      fullWidth: true,
                      onPressed: () => _showChangePasswordBottomSheet(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: AppButton(
                      label: 'Settings',
                      fullWidth: true,
                      onPressed: () => context.push('/settings'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: AppButton(
                      label: 'Logout',
                      fullWidth: true,
                      useSolidBackground: true,
                      onPressed: () async {
                        final confirmed = await ConfirmationDialog.show(
                          context,
                          title: 'Sign Out',
                          message:
                              'Are you sure you want to sign out from your account?',
                          confirmLabel: 'Sign Out',
                          isDangerous: true,
                        );
                        if (confirmed && context.mounted) {
                          await ref.read(authProvider.notifier).logout();
                        }
                      },
                      backgroundColor: AppColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
