import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/notification_card.dart';
import '../../../widgets/domain/rent_breakdown_card.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/confirmation_dialog.dart';
import '../../../widgets/ui/state_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDashboard = ref.watch(activeDashboardProvider);
    final asyncHistory = ref.watch(activeHistoryProvider(1));
    final asyncNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(
        title: 'Dashboard',
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Sign Out',
                message: 'Are you sure you want to sign out from your account?',
                confirmLabel: 'Sign Out',
                isDangerous: true,
              );
              if (confirmed && context.mounted) {
                await ref.read(authProvider.notifier).logout();
              }
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: asyncDashboard.when(
        loading: () => const AppLoader(),
        error: (error, stack) => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: StateCard(
            message: 'Failed to load dashboard',
            variant: StateCardVariant.error,
          ),
        ),
        data: (data) {
          final flatItems = data.availableFlats
              .map((flat) => FlatModel(id: flat.id, label: flat.label))
              .toList();
          final notificationSection = asyncNotifications.when<Widget?>(
            loading: () => const AppLoader(),
            error: (_, __) =>
                const StateCard(message: 'Notifications unavailable'),
            data: (items) {
              final activeItems =
                  items.where((item) => !item.isExpired).toList();
              if (activeItems.isEmpty) {
                return null;
              }

              final latest = activeItems.first;
              return NotificationCard(
                title: latest.title,
                message: latest.message,
                targetType: latest.targetType,
                expiresAt: latest.expiresAt,
              );
            },
          );

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: <Widget>[
              if (flatItems.isNotEmpty)
                FadeSlideTransition(
                  child: FlatSelector(flats: flatItems),
                ),
              if (flatItems.isNotEmpty) const SizedBox(height: AppSpacing.md),
              if (notificationSection != null) ...<Widget>[
                FadeSlideTransition(
                  duration: AppAnimations.normal,
                  child: notificationSection,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              ScaleInAnimation(
                duration: AppAnimations.normal,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Total Outstanding',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          formatINR(data.totalOutstanding),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.violet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              asyncHistory.when(
                loading: () => const AppLoader(),
                error: (_, __) =>
                    const StateCard(message: 'History unavailable'),
                data: (history) {
                  if (history.items.isEmpty) {
                    return const StateCard(
                        message: 'No rent history available');
                  }
                  return Column(
                    children: history.items
                        .take(2)
                        .map(
                          (item) => FadeSlideTransition(
                            child: RentBreakdownCard(
                              monthLabel: item.monthLabel,
                              status: item.status,
                              baseRent: item.baseRent,
                              utilityBill: item.utilityBill,
                              maintenance: item.maintenance,
                              previousDues: item.previousDues,
                              totalDue: item.totalDue,
                              paidAmount: item.paidAmount,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
