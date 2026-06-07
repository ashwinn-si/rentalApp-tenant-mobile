import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/notification_card.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(
        title: 'Notifications',
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
          error: (_, __) => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: StateCard(
                message: 'Unable to load notifications',
                variant: StateCardVariant.error),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: StateCard(message: 'No notifications found'),
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
