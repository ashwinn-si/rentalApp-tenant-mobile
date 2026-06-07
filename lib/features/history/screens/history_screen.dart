import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/providers/error_handler_provider.dart';
import '../../../core/utils/animations.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/domain/rent_breakdown_card.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/chart_widgets.dart';
import '../../../widgets/ui/pagination_footer.dart';
import '../../../widgets/ui/empty_state_card.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/history_provider.dart';

extension _BreakdownBuilder on RentBarItem {
  List<BreakdownItem> toBreakdownItems() => [
        BreakdownItem(
          label: 'Base Rent',
          amount: baseRent,
          color: AppColors.violet,
        ),
        BreakdownItem(
          label: 'Utility Bill',
          amount: utilityBill,
          color: const Color(0xFF06B6D4),
        ),
        if (maintenance > 0)
          BreakdownItem(
            label: 'Maintenance',
            amount: maintenance,
            color: const Color(0xFFF59E0B),
          ),
      ];
}

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
    final asyncLast3Months = ref.watch(last3MonthsComparisonProvider);

    developer.log(
        '[HistoryScreen] Build - asyncHistory: ${asyncHistory.runtimeType}, page=$_page, value: ${asyncHistory.valueOrNull}, error: ${asyncHistory.error}');

    return asyncDashboard.when(
      loading: () => ListPageTemplate(
        title: 'History',
        isLoading: true,
        actions: _refreshAction,
        body: const SizedBox.shrink(),
      ),
      error: (error, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ApiErrorHandler.handleAccessDenied(error, ref);
        });
        return ListPageTemplate(
          title: 'History',
          errorMessage: 'Unable to load history',
          actions: _refreshAction,
          body: const SizedBox.shrink(),
        );
      },
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
          error: (error, __) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ApiErrorHandler.handleAccessDenied(error, ref);
            });
            return ListPageTemplate(
              title: 'History',
              errorMessage: 'Unable to load history',
              actions: _refreshAction,
              body: const SizedBox.shrink(),
            );
          },
          data: (history) {
            final recentBarData = asyncLast3Months.when(
              loading: () => <RentBarItem>[],
              error: (_, __) => <RentBarItem>[],
              data: (last3Data) => last3Data.items
                  .map(
                    (item) => RentBarItem(
                      monthLabel: item.monthLabel,
                      baseRent: item.baseRent,
                      utilityBill: item.utility,
                      maintenance: item.maintenance,
                    ),
                  )
                  .toList(),
            );

            // Empty state
            if (history.items.isEmpty && recentBarData.isEmpty) {
              return ListPageTemplate(
                title: 'History',
                actions: _refreshAction,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: const EmptyStateCard(
                      type: EmptyStateType.history,
                    ),
                  ),
                ),
              );
            }

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
                      if (recentBarData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            children: [
                              PremiumCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: AppSpacing.xs,
                                        bottom: AppSpacing.sm,
                                      ),
                                      child: Text(
                                        'Recent Rent Breakdown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    RentPercentageTable(data: recentBarData),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              PremiumCard(
                                child: RentBreakdownPieChart(
                                  items: recentBarData.first.toBreakdownItems(),
                                  monthLabel: recentBarData.first.monthLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      _RentCardsSection(
                        activeFlatId: dashboardData.availableFlats.isNotEmpty
                            ? dashboardData.availableFlats.first.id
                            : null,
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

class _RentCardsSection extends ConsumerStatefulWidget {
  const _RentCardsSection({
    required this.activeFlatId,
  });

  final String? activeFlatId;

  @override
  ConsumerState<_RentCardsSection> createState() => _RentCardsSectionState();
}

class _RentCardsSectionState extends ConsumerState<_RentCardsSection> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final asyncCards = ref.watch(
      historyCardsProvider(
        HistoryCardsParams(
          page: _currentPage,
          flatId: widget.activeFlatId,
        ),
      ),
    );

    return asyncCards.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: AppLoader(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (response) {
        if (response.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            ...response.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: RentBreakdownCard(
                  monthLabel:
                      '${_getMonthName(item.month)} ${item.year}',
                  flatLabel: item.flatLabel,
                  status: item.status,
                  baseRent: item.baseRent,
                  utilityBill: item.utilityBill,
                  maintenance: item.maintenance,
                  extra: item.extra,
                  previousDues: 0,
                  totalDue: item.totalDue,
                  paidAmount: item.paidAmount,
                  maintenanceBreakdownItems: item.maintenanceBreakdown,
                ),
              ),
            ),
            if (response.pagination.totalPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: PaginationFooter(
                  currentPage: response.pagination.page,
                  totalPages: response.pagination.totalPages,
                  onPreviousPressed: response.pagination.page > 1
                      ? () => setState(
                          () => _currentPage = response.pagination.page - 1)
                      : null,
                  onNextPressed:
                      response.pagination.page <
                          response.pagination.totalPages
                          ? () => setState(
                              () =>
                                  _currentPage =
                                      response.pagination.page + 1)
                          : null,
                ),
              ),
          ],
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
