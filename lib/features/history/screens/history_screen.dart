import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/domain/rent_breakdown_card.dart';
import '../../../widgets/domain/simple_paginator.dart';
import '../../../widgets/ui/chart_widgets.dart';
import '../../../widgets/ui/skeleton_card.dart';
import '../../../widgets/ui/state_card.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final asyncHistory = ref.watch(activeHistoryProvider(_page));
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'History'),
      body: asyncDashboard.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const <Widget>[SkeletonCard(), SkeletonCard(), SkeletonCard()],
        ),
        error: (_, __) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const <Widget>[
            SkeletonCard(),
            SkeletonCard(),
            SkeletonCard(),
          ],
        ),
        data: (dashboardData) {
          final flatItems = dashboardData.availableFlats
              .map((flat) => FlatModel(id: flat.id, label: flat.label))
              .toList();

          return asyncHistory.when(
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const <Widget>[SkeletonCard(), SkeletonCard()],
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: StateCard(message: 'Unable to load history', variant: StateCardVariant.error),
            ),
            data: (history) {
              final barData = history.items
                  .map((item) => RentBarItem(monthLabel: item.monthLabel, total: item.totalDue))
                  .toList();
              final lineData = history.items
                  .map((item) => RentLineItem(monthLabel: item.monthLabel, due: item.totalDue, paid: item.paidAmount))
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: <Widget>[
                  if (flatItems.isNotEmpty)
                    FadeSlideTransition(
                      child: FlatSelector(flats: flatItems),
                    ),
                  if (flatItems.isNotEmpty) const SizedBox(height: AppSpacing.md),
                  if (history.items.length >= 2) ...<Widget>[
                    FadeSlideTransition(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Rent Breakdown',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          RentStackedBarChart(data: barData),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeSlideTransition(
                      duration: AppAnimations.normal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Due vs Paid Trend',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          RentTrendLineChart(data: lineData),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  ...history.items.map(
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
                  ),
                  if (history.totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: FadeSlideTransition(
                        child: SimplePaginator(
                          page: history.page,
                          totalPages: history.totalPages,
                          onPrev: () => setState(() => _page = (_page - 1).clamp(1, history.totalPages)),
                          onNext: () => setState(() => _page = (_page + 1).clamp(1, history.totalPages)),
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
