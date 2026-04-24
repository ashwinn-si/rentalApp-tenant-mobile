import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../providers/maintenance_provider.dart';
import 'widgets/maintenance_issue_card.dart';

class IssueHistoryScreen extends ConsumerWidget {
  const IssueHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncIssues = ref.watch(maintenanceIssuesProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(
        title: 'Maintenance',
        actions: [
          IconButton(
            onPressed: () => context.push('/maintenance/report'),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Report Issue',
          ),
        ],
      ),
      body: ScreenBackground(
        child: asyncIssues.when(
          loading: () => const AppLoader(),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: StateCard(
              message: error.toString(),
              variant: StateCardVariant.error,
            ),
          ),
          data: (response) {
            if (response.issues.isEmpty) {
              return Center(
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
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(maintenanceIssuesProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: response.issues.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return MaintenanceIssueCard(issue: response.issues[index]);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/maintenance/report'),
        backgroundColor: AppColors.violet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
