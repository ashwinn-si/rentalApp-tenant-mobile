import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/notification_card.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/empty_state_card.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0B14) : AppColors.screenBg,
      appBar: buildPremiumAppBar(
        title: 'Alerts',
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(notificationsProvider);
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: ScreenBackground(
        child: asyncNotifications.when(
          loading: () => const AppLoader(),
          error: (_, __) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: EmptyStateCard(
                  type: EmptyStateType.notifications,
                  title: 'Unable to Load',
                  message: 'Failed to load notifications. Please try again.',
                ),
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: EmptyStateCard(
                      type: EmptyStateType.notifications,
                    ),
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                StaggeredListView(
                  children: items
                      .map(
                        (item) => NotificationCard(
                          title: item.title,
                          message: item.message,
                          targetType: item.targetType,
                          expiresAt: item.expiresAt,
                          isExpired: false,
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
