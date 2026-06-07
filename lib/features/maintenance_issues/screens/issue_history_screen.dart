import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/pagination_footer.dart';
import '../../../widgets/ui/empty_state_card.dart';
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
  late int totalPages;

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    itemsPerPage = 5;
    totalPages = 0;
  }

  List<Widget> get _refreshAction => [
        IconButton(
          onPressed: () => ref.invalidate(maintenanceIssuesProvider),
          icon: const Icon(Icons.refresh_outlined, color: Colors.white),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final asyncIssues = ref.watch(
        maintenanceIssuesProvider((page: currentPage, limit: itemsPerPage)));
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return asyncDashboard.when(
      loading: () => ListPageTemplate(
        title: 'Maintenance',
        isLoading: true,
        actions: _refreshAction,
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
        actions: _refreshAction,
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
        actions: _refreshAction,
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
        actions: _refreshAction,
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
        totalPages = (response.total / itemsPerPage).ceil();

        // Empty state
        if (response.issues.isEmpty && currentPage == 1) {
          return ListPageTemplate(
            title: 'Maintenance',
            actions: _refreshAction,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: EmptyStateCard(
                  type: EmptyStateType.maintenance,
                  actionLabel: 'Report New Issue',
                  onActionPressed: () => context.push('/maintenance/report'),
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
        final isSingleItem = response.issues.length == 1 && totalPages == 1;

        return ListPageTemplate(
          title: 'Maintenance',
          actions: _refreshAction,
          body: isSingleItem
              ? RefreshIndicator(
                  onRefresh: () => ref.refresh(maintenanceIssuesProvider(
                      (page: currentPage, limit: itemsPerPage)).future),
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
                      (page: currentPage, limit: itemsPerPage)).future),
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      bottom: totalPages > 1 ? 100 : AppSpacing.md,
                    ),
                    itemCount: response.issues.length +
                        (totalPages > 1 ? 1 : 0) +
                        (dashboardData.availableFlats.isNotEmpty ? 1 : 0),
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

                      final issueIndex = dashboardData.availableFlats.isNotEmpty ? index - 1 : index;

                      // Last item is pagination
                      if (totalPages > 1 && issueIndex == response.issues.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: PaginationFooter(
                            currentPage: currentPage,
                            totalPages: totalPages,
                            onPreviousPressed: currentPage > 1
                                ? () => setState(() => currentPage--)
                                : null,
                            onNextPressed: currentPage < totalPages
                                ? () => setState(() => currentPage++)
                                : null,
                          ),
                        );
                      }

                      final issue = response.issues[issueIndex];
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
}
