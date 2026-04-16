import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/animations.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_text_field.dart';
import '../providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ToastService.showError('All fields are required');
      return;
    }
    if (newPassword.length < 8) {
      ToastService.showError('New password must be at least 8 characters');
      return;
    }
    if (newPassword != confirmPassword) {
      ToastService.showError('Passwords do not match');
      return;
    }

    final error = await ref.read(authProvider.notifier).changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
    if (error != null) {
      ToastService.showError(error);
    } else {
      ToastService.showSuccess('Password updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authProvider.select((state) => state.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 4,
        shadowColor: AppColors.violet.withOpacity(0.3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              FadeSlideTransition(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.pending.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.pending.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.pending,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Text(
                          'You must change your password to continue',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.pending,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideTransition(
                duration: const Duration(milliseconds: 300),
                child: AppTextField(
                  label: 'Current Password',
                  obscureText: true,
                  controller: _currentPasswordController,
                  prefixIcon: Icons.lock_outlined,
                ),
              ),
              FadeSlideTransition(
                duration: const Duration(milliseconds: 400),
                child: AppTextField(
                  label: 'New Password',
                  obscureText: true,
                  controller: _newPasswordController,
                  prefixIcon: Icons.lock_open_outlined,
                  helperText: 'Minimum 8 characters',
                ),
              ),
              FadeSlideTransition(
                duration: const Duration(milliseconds: 500),
                child: AppTextField(
                  label: 'Confirm New Password',
                  obscureText: true,
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.verified_user_outlined,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideTransition(
                duration: const Duration(milliseconds: 600),
                child: AppButton(
                  label: 'Update Password',
                  onPressed: _submit,
                  isLoading: isLoading,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
