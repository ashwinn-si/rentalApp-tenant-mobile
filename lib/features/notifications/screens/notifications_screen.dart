import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/domain/notification_card.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/state_card.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifications = ref.watch(notificationsProvider);
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Notifications'),
      body: asyncDashboard.when(
        loading: () => const AppLoader(),
        error: (_, __) => const AppLoader(),
        data: (dashboardData) {
          final flatItems = dashboardData.availableFlats
              .map((flat) => FlatModel(id: flat.id, label: flat.label))
              .toList();

          return asyncNotifications.when(
            loading: () => const AppLoader(),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: StateCard(
                  message: 'Unable to load notifications',
                  variant: StateCardVariant.error),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: <Widget>[
                      if (flatItems.isNotEmpty)
                        FadeSlideTransition(
                          child: FlatSelector(flats: flatItems),
                        ),
                      if (flatItems.isNotEmpty)
                        const SizedBox(height: AppSpacing.md),
                      const Expanded(
                        child: StateCard(message: 'No notifications found'),
                      ),
                    ],
                  ),
                );
              }

              final active = items.where((item) => !item.isExpired).toList();
              final expired = items.where((item) => item.isExpired).toList();

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: <Widget>[
                  if (flatItems.isNotEmpty)
                    FadeSlideTransition(
                      child: FlatSelector(flats: flatItems),
                    ),
                  if (flatItems.isNotEmpty)
                    const SizedBox(height: AppSpacing.md),
                  FadeSlideTransition(
                    child: Text(
                      'Active (${active.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...active.map(
                    (item) => FadeSlideTransition(
                      child: NotificationCard(
                        title: item.title,
                        message: item.message,
                        targetType: item.targetType,
                        expiresAt: item.expiresAt,
                        isExpired: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideTransition(
                    duration: AppAnimations.normal,
                    child: Text(
                      'Expired (${expired.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...expired.map(
                    (item) => FadeSlideTransition(
                      child: NotificationCard(
                        title: item.title,
                        message: item.message,
                        targetType: item.targetType,
                        expiresAt: item.expiresAt,
                        isExpired: true,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
