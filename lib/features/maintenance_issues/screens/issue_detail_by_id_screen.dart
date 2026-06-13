import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/screen_background.dart';
import '../providers/maintenance_provider.dart';
import 'issue_detail_screen.dart';

class IssueDetailByIdScreen extends ConsumerWidget {
  const IssueDetailByIdScreen({super.key, required this.issueId});

  final String issueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueAsync = ref.watch(maintenanceIssueDetailProvider(issueId));

    return issueAsync.when(
      loading: () => Scaffold(
        appBar: buildPremiumAppBar(title: 'Issue Details'),
        body: const ScreenBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => Scaffold(
        appBar: buildPremiumAppBar(title: 'Issue Details'),
        body: ScreenBackground(
          child: Center(
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Text(
                  'Could not load issue',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      data: (issue) => IssueDetailScreen(issue: issue),
    );
  }
}
