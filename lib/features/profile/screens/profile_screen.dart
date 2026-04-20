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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Profile'),
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
                      backgroundColor: const Color(0xFFDC2626),
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
