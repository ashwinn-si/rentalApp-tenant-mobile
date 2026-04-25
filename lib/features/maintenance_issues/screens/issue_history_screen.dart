import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/pagination_footer.dart';
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

  @override
  Widget build(BuildContext context) {
    final asyncIssues = ref.watch(
        maintenanceIssuesProvider((page: currentPage, limit: itemsPerPage)));

    return asyncIssues.when(
      loading: () => ListPageTemplate(
        title: 'Maintenance',
        isLoading: true,
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/maintenance/report'),
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          label: const Text('Report'),
          icon: const Icon(Icons.add),
          elevation: 4,
        ),
      ),
      error: (error, _) => ListPageTemplate(
        title: 'Maintenance',
        errorMessage: error.toString(),
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/maintenance/report'),
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          label: const Text('Report'),
          icon: const Icon(Icons.add),
          elevation: 4,
        ),
      ),
      data: (response) {
        totalPages = (response.total / itemsPerPage).ceil();

        // Empty state
        if (response.issues.isEmpty && currentPage == 1) {
          return ListPageTemplate(
            title: 'Maintenance',
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'No issues reported yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Any maintenance issues you report will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/maintenance/report'),
                      icon: const Icon(Icons.add),
                      label: const Text('Report New Issue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.push('/maintenance/report'),
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              label: const Text('Report'),
              icon: const Icon(Icons.add),
              elevation: 4,
            ),
          );
        }

        // List with pagination
        final isSingleItem = response.issues.length == 1 && totalPages == 1;

        return ListPageTemplate(
          title: 'Maintenance',
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
                          children: response.issues
                              .map((issue) => MaintenanceIssueCard(
                                    issue: issue,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              IssueDetailScreen(issue: issue),
                                        ),
                                      );
                                    },
                                  ))
                              .toList(),
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
                    itemCount:
                        response.issues.length + (totalPages > 1 ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      // Last item is pagination
                      if (totalPages > 1 && index == response.issues.length) {
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

                      final issue = response.issues[index];
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/maintenance/report'),
            backgroundColor: AppColors.violet,
            foregroundColor: Colors.white,
            label: const Text('Report'),
            icon: const Icon(Icons.add),
            elevation: 4,
          ),
        );
      },
    );
  }
}
