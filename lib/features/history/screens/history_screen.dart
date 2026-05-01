import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/domain/rent_breakdown_card.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/chart_widgets.dart';
import '../../../widgets/ui/pagination_footer.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _page = 1;

  List<Widget> get _refreshAction => [
        IconButton(
          onPressed: () {
            ref.invalidate(historyProvider);
            ref.invalidate(activeHistoryProvider);
            ref.invalidate(dashboardProvider);
            ref.invalidate(activeDashboardProvider);
          },
          icon: const Icon(Icons.refresh_outlined, color: Colors.white),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      authProvider.select((state) => state.activeFlatId),
      (prev, next) {
        if (prev != next && mounted) {
          setState(() => _page = 1);
        }
      },
    );

    final asyncHistory = ref.watch(activeHistoryProvider(_page));
    final asyncDashboard = ref.watch(activeDashboardProvider);

    developer.log(
        '[HistoryScreen] Build - asyncHistory: ${asyncHistory.runtimeType}, page=$_page, value: ${asyncHistory.valueOrNull}, error: ${asyncHistory.error}');

    return asyncDashboard.when(
      loading: () => ListPageTemplate(
        title: 'History',
        isLoading: true,
        actions: _refreshAction,
        body: const SizedBox.shrink(),
      ),
      error: (_, __) => ListPageTemplate(
        title: 'History',
        errorMessage: 'Unable to load history',
        actions: _refreshAction,
        body: const SizedBox.shrink(),
      ),
      data: (dashboardData) {
        final flatItems = dashboardData.availableFlats
            .map((flat) => FlatModel(id: flat.id, label: flat.label))
            .toList();

        return asyncHistory.when(
          loading: () => ListPageTemplate(
            title: 'History',
            isLoading: true,
            actions: _refreshAction,
            body: const SizedBox.shrink(),
          ),
          error: (_, __) => ListPageTemplate(
            title: 'History',
            errorMessage: 'Unable to load history',
            actions: _refreshAction,
            body: const SizedBox.shrink(),
          ),
          data: (history) {
            final recentBarData = dashboardData.recentRents
                .map(
                  (r) => RentBarItem(
                    monthLabel: r.isCurrentMonth ? 'This Month' : r.monthLabel,
                    baseRent: r.baseRent,
                    utilityBill: r.utilityBill,
                    maintenance: r.maintenanceShare,
                  ),
                )
                .toList();

            final currentMonthRent = dashboardData.recentRents
                .where((r) => r.isCurrentMonth)
                .firstOrNull;
            final currentMonthBreakdown = currentMonthRent != null
                ? <BreakdownItem>[
                    BreakdownItem(
                      label: 'Base Rent',
                      amount: currentMonthRent.baseRent,
                      color: const Color(0xFF7C3AED),
                    ),
                    BreakdownItem(
                      label: 'Utility Bill',
                      amount: currentMonthRent.utilityBill,
                      color: const Color(0xFF06B6D4),
                    ),
                    BreakdownItem(
                      label: 'Maintenance',
                      amount: currentMonthRent.maintenanceShare,
                      color: const Color(0xFFF59E0B),
                    ),
                  ]
                : <BreakdownItem>[];

            return ListPageTemplate(
              title: 'History',
              actions: _refreshAction,
              body: ListView(
                padding: EdgeInsets.only(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  bottom: history.totalPages > 1 ? 100 : AppSpacing.md,
                ),
                children: [
                  StaggeredListView(
                    children: [
                      if (flatItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: FlatSelector(flats: flatItems),
                        ),
                      if (currentMonthBreakdown.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: PremiumCard(
                            child: RentBreakdownPieChart(
                              items: currentMonthBreakdown,
                              monthLabel: currentMonthRent?.monthLabel,
                            ),
                          ),
                        ),
                      if (recentBarData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: PremiumCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: AppSpacing.xs,
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: Text(
                                    'This Month',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                RentStackedBarChart(data: recentBarData),
                              ],
                            ),
                          ),
                        ),
                      ...history.items.map(
                        (item) => RentBreakdownCard(
                          monthLabel: item.monthLabel,
                          status: item.status,
                          baseRent: item.baseRent,
                          utilityBill: item.utilityBill,
                          maintenance: item.maintenance,
                          previousDues: item.previousDues,
                          totalDue: item.totalDue,
                          paidAmount: item.paidAmount,
                          maintenanceBreakdownItems:
                              item.maintenanceBreakdownItems,
                        ),
                      ),
                      if (history.totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: PaginationFooter(
                            currentPage: history.page,
                            totalPages: history.totalPages,
                            onPreviousPressed: history.page > 1
                                ? () => setState(() => _page = history.page - 1)
                                : null,
                            onNextPressed: history.page < history.totalPages
                                ? () => setState(() => _page = history.page + 1)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
