import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/pagination_footer.dart';
import '../../../widgets/ui/empty_state_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/maintenance_provider.dart';
import 'issue_detail_screen.dart';
import 'widgets/maintenance_issue_card.dart';

class IssueHistoryScreen extends ConsumerStatefulWidget {
  const IssueHistoryScreen({super.key});

  @override
  ConsumerState<IssueHistoryScreen> createState() => _IssueHistoryScreenState();
}

class _IssueHistoryScreenState extends ConsumerState<IssueHistoryScreen> {
  late int currentPage;
  late int itemsPerPage;
  String? selectedStatus; // null = all, 'submitted', 'under_review', 'resolved', 'rejected'

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    itemsPerPage = 10;
  }

  List<Widget> _refreshAction(String? flatId) => [
        IconButton(
          onPressed: () {
            ref.invalidate(
              maintenanceIssuesProvider(
                MaintenanceIssuesParams(
                  flatId: flatId,
                  status: selectedStatus,
                  page: currentPage,
                  limit: itemsPerPage,
                ),
              ),
            );
          },
          icon: const Icon(Icons.refresh_outlined, color: Colors.white),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final activeFlatId = authState.activeFlatId;

    ref.listen<String?>(
      authProvider.select((state) => state.activeFlatId),
      (prev, next) {
        if (prev != next && mounted) {
          setState(() => currentPage = 1);
        }
      },
    );

    final asyncIssues = ref.watch(
      maintenanceIssuesProvider(
        MaintenanceIssuesParams(
          flatId: activeFlatId,
          status: selectedStatus,
          page: currentPage,
          limit: itemsPerPage,
        ),
      ),
    );
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return asyncDashboard.when(
      loading: () => ListPageTemplate(
        title: 'Maintenance',
        isLoading: true,
        actions: _refreshAction(activeFlatId),
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/maintenance/report'),
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      ),
      error: (_, __) => ListPageTemplate(
        title: 'Maintenance',
        errorMessage: 'Error loading flats',
        actions: _refreshAction(activeFlatId),
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/maintenance/report'),
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      ),
      data: (dashboardData) => asyncIssues.when(
      loading: () => ListPageTemplate(
        title: 'Maintenance',
        isLoading: true,
        actions: _refreshAction(activeFlatId),
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/maintenance/report'),
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      ),
      error: (error, _) => ListPageTemplate(
        title: 'Maintenance',
        errorMessage: error.toString(),
        actions: _refreshAction(activeFlatId),
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/maintenance/report'),
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      ),
      data: (response) {
        final pagination = response.pagination;

        // Empty state
        if (response.issues.isEmpty && currentPage == 1) {
          final flatItems = dashboardData.availableFlats
              .map((flat) => FlatModel(id: flat.id, label: flat.label))
              .toList();

          return ListPageTemplate(
            title: 'Maintenance',
            actions: _refreshAction(activeFlatId),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    if (flatItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: FlatSelector(flats: flatItems),
                      ),
                    _buildStatusFilter(),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.15,
                        ),
                        child: EmptyStateCard(
                          type: EmptyStateType.maintenance,
                          actionLabel: 'Report New Issue',
                          onActionPressed: () => context.push('/maintenance/report'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.push('/maintenance/report'),
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add),
            ),
          );
        }

        // List with pagination
        final isSingleItem = response.issues.length == 1 && pagination!.totalPages == 1;

        return ListPageTemplate(
          title: 'Maintenance',
          actions: _refreshAction(activeFlatId),
          body: isSingleItem
              ? RefreshIndicator(
                  onRefresh: () => ref.refresh(maintenanceIssuesProvider(
                    MaintenanceIssuesParams(
                      flatId: activeFlatId,
                      status: selectedStatus,
                      page: currentPage,
                      limit: itemsPerPage,
                    ),
                  ).future),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 180,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (dashboardData.availableFlats.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                child: FlatSelector(
                                  flats: dashboardData.availableFlats
                                      .map((flat) => FlatModel(id: flat.id, label: flat.label))
                                      .toList(),
                                ),
                              ),
                            _buildStatusFilter(),
                            ...response.issues.map((issue) => MaintenanceIssueCard(
                              issue: issue,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        IssueDetailScreen(issue: issue),
                                  ),
                                );
                              },
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.refresh(maintenanceIssuesProvider(
                    MaintenanceIssuesParams(
                      flatId: activeFlatId,
                      status: selectedStatus,
                      page: currentPage,
                      limit: itemsPerPage,
                    ),
                  ).future),
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      bottom: pagination!.totalPages > 1 ? 100 : AppSpacing.md,
                    ),
                    itemCount: response.issues.length +
                        (pagination!.totalPages > 1 ? 1 : 0) +
                        (dashboardData.availableFlats.isNotEmpty ? 1 : 0) +
                        1, // status filter is always shown
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      // First item is flat selector
                      if (index == 0 && dashboardData.availableFlats.isNotEmpty) {
                        return FlatSelector(
                          flats: dashboardData.availableFlats
                              .map((flat) => FlatModel(id: flat.id, label: flat.label))
                              .toList(),
                        );
                      }

                      // Second item is status filter
                      final filterIndex = dashboardData.availableFlats.isNotEmpty ? 1 : 0;
                      if (index == filterIndex) {
                        return _buildStatusFilter();
                      }

                      final issueIndex = filterIndex + 1;
                      final dataIndex = index - issueIndex;

                      // Last item is pagination
                      if (pagination!.totalPages > 1 && dataIndex == response.issues.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: PaginationFooter(
                            currentPage: pagination!.page,
                            totalPages: pagination!.totalPages,
                            onPreviousPressed: pagination!.page > 1
                                ? () => setState(() => currentPage = pagination!.page - 1)
                                : null,
                            onNextPressed: pagination!.page < pagination!.totalPages
                                ? () => setState(() => currentPage = pagination!.page + 1)
                                : null,
                          ),
                        );
                      }

                      final issue = response.issues[dataIndex];
                      return MaintenanceIssueCard(
                        issue: issue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => IssueDetailScreen(issue: issue),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/maintenance/report'),
            backgroundColor: AppColors.violet,
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.add),
          ),
        );
      },
      ),
    );
  }

  Widget _buildStatusFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterBg = isDark ? const Color(0xFF2C2550) : AppColors.violet.withValues(alpha: 0.08);
    final selectedBg = AppColors.violet;
    final selectedText = Colors.white;
    final unselectedText = isDark ? const Color(0xFFF3F4F6) : AppColors.textPrimary;

    final statuses = [
      {'value': null, 'label': 'All'},
      {'value': 'submitted', 'label': 'Submitted'},
      {'value': 'under_review', 'label': 'Under Review'},
      {'value': 'resolved', 'label': 'Resolved'},
      {'value': 'rejected', 'label': 'Rejected'},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((status) {
            final isSelected = selectedStatus == status['value'];
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(
                  status['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? selectedText : unselectedText,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selectedStatus = status['value'] as String?;
                    currentPage = 1;
                  });
                },
                backgroundColor: filterBg,
                selectedColor: selectedBg,
                side: BorderSide(
                  color: isSelected ? selectedBg : AppColors.violet.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
