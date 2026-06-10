import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/providers/error_handler_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/dashboard_notification_card.dart';
import '../../../widgets/domain/rent_breakdown_card.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/confirmation_dialog.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../../app_version/services/app_update_checker.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/data/models/history_response.dart';
import '../../history/providers/history_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../data/models/dashboard_response.dart';
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

  void _autoSelectFirstFlat(WidgetRef ref, DashboardResponse data) {
    final currentActiveFlatId = ref.read(authProvider.select((state) => state.activeFlatId));
    if (currentActiveFlatId == null && data.availableFlats.isNotEmpty) {
      final firstFlatId = data.availableFlats.first.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(authProvider.notifier).setActiveFlatId(firstFlatId);
        }
      });
    }
  }

  String _getMonthYearLabel(Map<String, dynamic>? data) {
    if (data == null) return '';
    // Use outstandingFrom when available — points to oldest unpaid month
    final outstandingFrom = data['outstandingFrom'] as Map<String, dynamic>?;
    if (outstandingFrom != null) {
      final label = outstandingFrom['monthLabel']?.toString();
      if (label != null && label.isNotEmpty) return label;
    }
    final month = data['rentMonth'] as int?;
    final year = data['rentYear'] as int?;
    if (month == null || year == null) return '';
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[month - 1]} $year';
  }

  @override
  Widget build(BuildContext context) {
    final asyncDashboard = ref.watch(activeDashboardProvider);
    final asyncHistory = ref.watch(activeHistoryProvider(1));
    final asyncNotifications = ref.watch(notificationsProvider);
    final asyncRentCards = ref.watch(activeRentCardsProvider);

    developer.log('[DashboardScreen] Build - asyncDashboard: ${asyncDashboard.runtimeType}, value: ${asyncDashboard.valueOrNull}, error: ${asyncDashboard.error}');

    return Scaffold(
      appBar: buildPremiumAppBar(
        title: 'Dashboard',
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ref.invalidate(dashboardProvider);
              ref.invalidate(activeDashboardProvider);
              ref.invalidate(historyProvider);
              ref.invalidate(activeHistoryProvider);
              ref.invalidate(notificationsProvider);
              ref.invalidate(rentCardsProvider);
              ref.invalidate(activeRentCardsProvider);
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
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
          error: (error, stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ApiErrorHandler.handleAccessDenied(error, ref);
            });
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: StateCard(
                message: 'Failed to load dashboard',
                variant: StateCardVariant.error,
              ),
            );
          },
          data: (data) {
            _autoSelectFirstFlat(ref, data);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final secondaryText =
                isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;
            final dividerColor =
                isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
            final flatItems = data.availableFlats
                .map((flat) => FlatModel(id: flat.id, label: flat.label))
                .toList();
            final notificationSection = asyncNotifications.when<Widget?>(
              loading: () => const AppLoader(),
              error: (_, __) => null,
              data: (items) {
                if (items.isEmpty) {
                  return null;
                }

                final latest = items.first;
                return DashboardNotificationCard(
                  notificationCount: items.length,
                  latestTitle: latest.title,
                  latestMessage: latest.message,
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
                          extra: item.extra,
                          previousDues: item.previousDues,
                          totalDue: item.totalDue,
                          paidAmount: item.paidAmount,
                          maintenanceBreakdownItems: item.maintenanceBreakdownItems,
                        ),
                      )
                      .toList(),
                );
              },
            );

            final rentCardsSection = asyncRentCards.when<Widget?>(
              loading: () => const AppLoader(),
              error: (_, __) => null,
              data: (rentCardsData) {
                if (rentCardsData.items.isEmpty) {
                  return null;
                }

                return StaggeredListView(
                  children: rentCardsData.items
                      .map(
                        (card) => RentBreakdownCard(
                          monthLabel: card.monthLabel,
                          status: card.status,
                          baseRent: card.baseRent,
                          utilityBill: card.utilityBill,
                          maintenance: card.maintenance,
                          extra: card.extra,
                          previousDues: card.previousDues,
                          totalDue: card.totalDue,
                          paidAmount: card.paidAmount,
                          flatLabel: card.flatLabel,
                          maintenanceBreakdownItems: card.maintenanceBreakdown
                              .map((item) => MaintenanceBreakdownItem(
                                    name: item.name,
                                    yourShare: item.yourShare,
                                    totalCost: item.totalCost,
                                    type: item.type,
                                    id: item.id,
                                    issueId: item.issueId,
                                  ))
                              .toList(),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info,
                              size: 14,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'OUTSTANDING',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        formatINR(data.totalOutstanding),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ref.watch(activeOutstandingDueProvider).when(
                        data: (due) => due.months.isEmpty
                            ? const SizedBox.shrink()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(height: 1, color: dividerColor),
                                  const SizedBox(height: AppSpacing.sm),
                                  ...due.months.map((month) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              month.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: secondaryText,
                                              ),
                                            ),
                                            Text(
                                              formatINR(month.amount),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              if (rentCardsSection != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Rent Cards',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                rentCardsSection,
              ],
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
