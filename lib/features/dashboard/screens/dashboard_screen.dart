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
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../../app_version/services/app_update_checker.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await checkForAppUpdate(
        context,
        notifyOptionalUpdate: true,
        showErrorToast: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: ScreenBackground(
        child: asyncDashboard.when(
          loading: () => const AppLoader(),
          error: (error, stack) => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: StateCard(
              message: 'Failed to load dashboard',
              variant: StateCardVariant.error,
            ),
          ),
          data: (data) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final secondaryText =
                isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;
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

            final historySection = asyncHistory.when(
              loading: () => const AppLoader(),
              error: (_, __) => const StateCard(message: 'History unavailable'),
              data: (history) {
                if (history.items.isEmpty) {
                  return const StateCard(message: 'No rent history available');
                }

                return StaggeredListView(
                  children: history.items
                      .take(2)
                      .map(
                        (item) => RentBreakdownCard(
                          monthLabel: item.monthLabel,
                          status: item.status,
                          baseRent: item.baseRent,
                          utilityBill: item.utilityBill,
                          maintenance: item.maintenance,
                          previousDues: item.previousDues,
                          totalDue: item.totalDue,
                          paidAmount: item.paidAmount,
                        ),
                      )
                      .toList(),
                );
              },
            );

            final children = <Widget>[
              if (flatItems.isNotEmpty) FlatSelector(flats: flatItems),
              if (flatItems.isNotEmpty) const SizedBox(height: AppSpacing.md),
              if (notificationSection != null) notificationSection,
              ScaleInAnimation(
                duration: AppAnimations.normal,
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Total Outstanding',
                        style: TextStyle(
                          color: secondaryText,
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
              historySection,
            ];

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    'Overview',
                    style: TextStyle(
                      color: secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                StaggeredListView(children: children),
              ],
            );
          },
        ),
      ),
    );
  }
}
