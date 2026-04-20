import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/confirmation_dialog.dart';
import '../../../widgets/ui/info_field.dart';
import '../../../widgets/ui/state_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Profile'),
      body: asyncProfile.when(
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
                InfoField(label: 'Name', value: profile.name),
                InfoField(label: 'Email', value: profile.email),
                InfoField(label: 'Phone', value: profile.phone),
                InfoField(
                    label: 'Alternate Phone', value: profile.alternatePhone),
                InfoField(label: 'Aadhaar', value: profile.aadhaarMasked),
                InfoField(label: 'PAN', value: profile.panMasked),
                InfoField(
                  label: 'Emergency Contact Name',
                  value: profile.emergencyName,
                ),
                InfoField(
                  label: 'Emergency Contact Relation',
                  value: profile.emergencyRelation,
                ),
                InfoField(
                  label: 'Emergency Phone',
                  value: profile.emergencyPhone,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: AppButton(
                    label: 'Logout',
                    fullWidth: true,
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
                    backgroundColor: AppColors.pending,
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
