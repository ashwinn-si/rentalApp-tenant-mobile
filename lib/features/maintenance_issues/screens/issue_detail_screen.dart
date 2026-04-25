import 'package:flutter/material.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/status_chip.dart';
import '../data/models/maintenance_issue.dart';
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
                              if (issue.adminRepairCost > 0) ...[
                                const SizedBox(height: AppSpacing.md),
                                const Divider(height: 1),
                                const SizedBox(height: AppSpacing.md),
                                _buildDetailRow(
                                  context,
                                  'Adjusted',
                                  formatINR(issue.adminRepairCost),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

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
