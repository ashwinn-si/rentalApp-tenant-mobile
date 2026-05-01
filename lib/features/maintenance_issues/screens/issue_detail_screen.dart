import 'package:flutter/material.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/status_chip.dart';
import '../data/models/maintenance_issue.dart'
    show MaintenanceIssue, AdjustmentDetails;
import 'widgets/image_carousel.dart';
import 'widgets/issue_timeline.dart';

class IssueDetailScreen extends StatelessWidget {
  const IssueDetailScreen({
    super.key,
    required this.issue,
  });

  final MaintenanceIssue issue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Issue Details'),
      body: ScreenBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xl + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image Carousel (if images exist)
                      ImageCarousel(
                        images: issue.images,
                        onImageTap: (imageUrl) =>
                            _showImagePreview(context, imageUrl),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Ticket Info Card
                      SizedBox(
                        width: double.infinity,
                        child: PremiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${issue.issueId}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                  StatusChip(
                                    status: _mapStatusToVariant(issue.status),
                                    label: issue.status
                                        .toUpperCase()
                                        .replaceAll('_', ' '),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                issue.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                issue.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Details Grid
                      SizedBox(
                        width: double.infinity,
                        child: PremiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                context,
                                'Category',
                                _toTitleCase(issue.category),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Divider(height: 1),
                              const SizedBox(height: AppSpacing.md),
                              _buildDetailRow(
                                context,
                                'Scope',
                                _toTitleCase(issue.scope),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Divider(height: 1),
                              const SizedBox(height: AppSpacing.md),
                              _buildDetailRow(
                                context,
                                'Created',
                                _formatDateTime(issue.createdAt),
                              ),
                              if (issue.tenantRepairCost > 0) ...[
                                const SizedBox(height: AppSpacing.md),
                                const Divider(height: 1),
                                const SizedBox(height: AppSpacing.md),
                                _buildDetailRow(
                                  context,
                                  'You Paid',
                                  formatINR(issue.tenantRepairCost),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Rent adjustment — feel-good banner
                      if (issue.status == 'resolved') ...[
                        if (issue.adjustmentDetails != null &&
                            issue.adjustmentDetails!.amount > 0)
                          _buildAdjustmentBanner(
                              context, issue.adjustmentDetails!)
                        else if (issue.adminRepairCost > 0)
                          _buildSimpleAdjustmentBanner(
                              context, issue.adminRepairCost),
                        if ((issue.adjustmentDetails != null &&
                                issue.adjustmentDetails!.amount > 0) ||
                            issue.adminRepairCost > 0)
                          const SizedBox(height: AppSpacing.lg),
                      ],

                      // Timeline
                      IssueTimeline(issue: issue),
                      const SizedBox(height: AppSpacing.lg),

                      // Admin Response (if exists)
                      if (issue.adminComments != null &&
                          issue.adminComments!.trim().isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: PremiumCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Response',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  issue.adminComments!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.6,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdjustmentBanner(BuildContext context, AdjustmentDetails adj) {
    final monthLabel = adj.adjustmentMonth != null && adj.adjustmentYear != null
        ? '${_monthName(adj.adjustmentMonth!)} ${adj.adjustmentYear}'
        : null;
    final headline = monthLabel != null
        ? '${formatINR(adj.amount)} deducted from your $monthLabel rent'
        : '${formatINR(adj.amount)} deducted from your rent';
    final sub = monthLabel != null
        ? 'Admin applied this to your $monthLabel rent record${adj.addToMaintenance ? ' via maintenance' : ''}.'
        : 'Admin has applied this adjustment against your rent.';

    return _emeraldBanner(context, headline, sub);
  }

  Widget _buildSimpleAdjustmentBanner(BuildContext context, num amount) {
    return _emeraldBanner(
      context,
      '${formatINR(amount)} deducted from your rent',
      'Admin has applied this adjustment against your rent.',
    );
  }

  Widget _emeraldBanner(BuildContext context, String headline, String sub) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_outlined,
                size: 18,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF14532D),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF166534),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
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
      'December',
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
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

  String _toTitleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
