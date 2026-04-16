import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/confirmation_dialog.dart';
import '../../../widgets/ui/info_field.dart';
import '../../../widgets/ui/skeleton_card.dart';
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
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const <Widget>[
            SkeletonCard(),
            SkeletonCard(),
            SkeletonCard()
          ],
        ),
        error: (_, __) => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: StateCard(
              message: 'Unable to load profile',
              variant: StateCardVariant.error),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            FadeSlideTransition(
                child: InfoField(label: 'Name', value: profile.name)),
            FadeSlideTransition(
                child: InfoField(label: 'Email', value: profile.email)),
            FadeSlideTransition(
                child: InfoField(label: 'Phone', value: profile.phone)),
            FadeSlideTransition(
                child: InfoField(
                    label: 'Alternate Phone', value: profile.alternatePhone)),
            FadeSlideTransition(
                child:
                    InfoField(label: 'Aadhaar', value: profile.aadhaarMasked)),
            FadeSlideTransition(
                child: InfoField(label: 'PAN', value: profile.panMasked)),
            FadeSlideTransition(
                child: InfoField(
                    label: 'Emergency Contact Name',
                    value: profile.emergencyName)),
            FadeSlideTransition(
                child: InfoField(
                    label: 'Emergency Contact Relation',
                    value: profile.emergencyRelation)),
            FadeSlideTransition(
                child: InfoField(
                    label: 'Emergency Phone', value: profile.emergencyPhone)),
            const SizedBox(height: AppSpacing.lg),
            FadeSlideTransition(
              duration: const Duration(milliseconds: 700),
              child: AppButton(
                label: 'Logout',
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
      ),
    );
  }
}
