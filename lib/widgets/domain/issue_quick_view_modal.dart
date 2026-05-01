import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/maintenance_issues/data/models/maintenance_issue.dart';
import '../../features/maintenance_issues/providers/maintenance_provider.dart';
import '../ui/status_chip.dart';

/// Shows a compact bottom-sheet with maintenance issue details.
/// Call [IssueQuickViewModal.show] from any widget.
class IssueQuickViewModal {
  IssueQuickViewModal._();

  static Future<void> show(BuildContext context, String issueMongoId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _IssueSheetContent(issueMongoId: issueMongoId),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _IssueSheetContent extends ConsumerWidget {
  const _IssueSheetContent({required this.issueMongoId});

  final String issueMongoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueAsync = ref.watch(maintenanceIssueDetailProvider(issueMongoId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final handle = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          issueAsync.when(
            loading: () => const _LoadingState(),
            error: (_, __) => const _ErrorState(),
            data: (issue) => _IssueBody(issue: issue),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(
        child: Text(
          'Could not load issue details',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _IssueBody extends StatelessWidget {
  const _IssueBody({required this.issue});

  final MaintenanceIssue issue;

  static RentStatus _mapStatus(String status) {
    switch (status) {
      case 'submitted':
        return RentStatus.pending;
      case 'under_review':
        return RentStatus.partial;
      case 'resolved':
        return RentStatus.paid;
      case 'rejected':
        return RentStatus.error;
      default:
        return RentStatus.pending;
    }
  }

  static String _titleCase(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFFF3F4F6) : AppColors.textPrimary;
    final secondary =
        isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;
    final dividerColor = secondary.withValues(alpha: 0.15);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Issue ID + status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '#${issue.issueId}',
              style: const TextStyle(
                color: AppColors.violet,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            StatusChip(
              status: _mapStatus(issue.status),
              label: _titleCase(issue.status),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Title
        Text(
          issue.title,
          style: TextStyle(
            color: primary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Description
        Text(
          issue.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: secondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: AppSpacing.md),

        // Category + scope pills
        Row(
          children: [
            _Pill(label: _titleCase(issue.category)),
            const SizedBox(width: AppSpacing.sm),
            _Pill(label: _titleCase(issue.scope)),
          ],
        ),

        // Cost rows
        if (issue.tenantRepairCost > 0 || issue.adminRepairCost > 0) ...[
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: AppSpacing.md),
          if (issue.tenantRepairCost > 0)
            _CostRow(
              label: 'You paid',
              value: formatINR(issue.tenantRepairCost),
              primary: primary,
              secondary: secondary,
            ),
          if (issue.adminRepairCost > 0)
            _CostRow(
              label: 'Extra Charge',
              value: formatINR(issue.adminRepairCost),
              primary: primary,
              secondary: secondary,
            ),
        ],

        // Admin note
        if (issue.adminComments != null &&
            issue.adminComments!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Admin note',
            style: TextStyle(
              color: secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            issue.adminComments!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: primary, fontSize: 13, height: 1.5),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.violet,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    required this.primary,
    required this.secondary,
  });

  final String label;
  final String value;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: secondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
