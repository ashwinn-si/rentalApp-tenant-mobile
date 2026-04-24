import 'package:flutter/material.dart';
import '../../../../core/constants/app_tokens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../widgets/ui/premium_card.dart';
import '../../../../widgets/ui/status_chip.dart';
import '../../data/models/maintenance_issue.dart';

class MaintenanceIssueCard extends StatelessWidget {
  const MaintenanceIssueCard({super.key, required this.issue});

  final MaintenanceIssue issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${issue.issueId}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  StatusChip(
                    status: _mapStatusToVariant(issue.status),
                    label: issue.status.toUpperCase().replaceAll('_', ' '),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            issue.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            issue.description,
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _buildInfoItem(
                context,
                Icons.category_outlined,
                issue.category,
              ),
              _buildInfoItem(
                context,
                Icons.calendar_today_outlined,
                _formatDate(issue.createdAt),
              ),
              if (issue.tenantRepairCost > 0)
                _buildInfoItem(
                  context,
                  Icons.payments_outlined,
                  'You paid: ${formatINR(issue.tenantRepairCost)}',
                ),
              if (issue.status == 'resolved' && issue.adminRepairCost > 0)
                _buildInfoItem(
                  context,
                  Icons.check_circle_outline,
                  'Adjusted: ${formatINR(issue.adminRepairCost)}',
                  color: AppColors.emerald,
                ),
            ],
          ),
          if (issue.adminComments != null && issue.adminComments!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADMIN RESPONSE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.adminComments!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final secondaryText = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF9CA3AF)
        : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? secondaryText),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.w500,
            color: color ?? secondaryText,
          ),
        ),
      ],
    );
  }

  RentStatus _mapStatusToVariant(String status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
