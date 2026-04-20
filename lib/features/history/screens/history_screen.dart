import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/domain/rent_breakdown_card.dart';
import '../../../widgets/domain/simple_paginator.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/chart_widgets.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
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

  Widget _buildLatestBreakdown(dynamic item) {
    final breakdownItems = <BreakdownItem>[
      BreakdownItem(
        label: 'Base Rent',
        amount: item.baseRent,
        color: const Color(0xFF7C3AED),
      ),
      BreakdownItem(
        label: 'Utility Bill',
        amount: item.utilityBill,
        color: const Color(0xFF06B6D4),
      ),
      BreakdownItem(
        label: 'Maintenance',
        amount: item.maintenance,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return RentBreakdownPieChart(items: breakdownItems);
  }

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

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'History'),
      body: ScreenBackground(
        child: asyncDashboard.when(
          loading: () => const AppLoader(),
          error: (_, __) => const AppLoader(),
          data: (dashboardData) {
            final flatItems = dashboardData.availableFlats
                .map((flat) => FlatModel(id: flat.id, label: flat.label))
                .toList();

            return asyncHistory.when(
              loading: () => const AppLoader(),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: StateCard(
                    message: 'Unable to load history',
                    variant: StateCardVariant.error),
              ),
              data: (history) {
                final barData = history.items
                    .map(
                      (item) => RentBarItem(
                        monthLabel: item.monthLabel,
                        baseRent: item.baseRent,
                        utilityBill: item.utilityBill,
                        maintenance: item.maintenance,
                      ),
                    )
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.md,
                  ),
                  children: [
                    StaggeredListView(
                      children: [
                        if (flatItems.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: FlatSelector(flats: flatItems),
                          ),
                        if (history.items.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: PremiumCard(
                              child: _buildLatestBreakdown(history.items.first),
                            ),
                          ),
                        if (history.items.length >= 2)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
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
                                      'Monthly Rent Breakdown',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  RentStackedBarChart(data: barData),
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
                            previousDues: 0,
                            totalDue: item.totalDue,
                            paidAmount: item.paidAmount,
                          ),
                        ),
                        if (history.totalPages > 1 || _page > 1)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.md,
                              bottom: AppSpacing.lg,
                            ),
                            child: SimplePaginator(
                              page: history.page,
                              totalPages: history.totalPages,
                              onPrev: () => setState(
                                () => _page = (history.page - 1).clamp(1, 9999),
                              ),
                              onNext: () => setState(
                                () => _page = (history.page + 1)
                                    .clamp(1, history.totalPages),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
