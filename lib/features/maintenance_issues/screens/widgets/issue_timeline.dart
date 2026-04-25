import 'package:flutter/material.dart';

import '../../../../core/constants/app_tokens.dart';
import '../../data/models/maintenance_issue.dart';

class IssueTimeline extends StatelessWidget {
  const IssueTimeline({
    super.key,
    required this.issue,
  });

  final MaintenanceIssue issue;

  @override
  Widget build(BuildContext context) {
    final timelineEvents = _buildTimelineEvents();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timelineEvents.length,
          itemBuilder: (context, index) {
            final event = timelineEvents[index];
            final isLast = index == timelineEvents.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event['color'] as Color,
                      ),
                      child: Center(
                        child: Icon(
                          event['icon'] as IconData,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: AppColors.violet.withOpacity(0.2),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['label'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event['timestamp'] as String,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildTimelineEvents() {
    final events = <Map<String, dynamic>>[
      {
        'label': 'Issue Reported',
        'timestamp': _formatDateTime(issue.createdAt),
        'icon': Icons.report_outlined,
        'color': AppColors.violet,
      },
    ];

    // Add status progression
    switch (issue.status) {
      case 'submitted':
        break;
      case 'under_review':
        events.add({
          'label': 'Under Review',
          'timestamp': 'Assigned to admin',
          'icon': Icons.schedule_outlined,
          'color': AppColors.orange,
        });
        break;
      case 'resolved':
        events.addAll([
          {
            'label': 'Under Review',
            'timestamp': 'Assigned to admin',
            'icon': Icons.schedule_outlined,
            'color': AppColors.orange,
          },
          {
            'label': 'Resolved',
            'timestamp': 'Work completed',
            'icon': Icons.check_circle_outlined,
            'color': AppColors.emerald,
          },
        ]);
        break;
      case 'rejected':
        events.add({
          'label': 'Rejected',
          'timestamp': 'Not approved',
          'icon': Icons.cancel_outlined,
          'color': AppColors.red,
        });
        break;
    }

    return events;
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year · $hour:$minute';
  }
}

extension AppColorsExtension on AppColors {
  static const orange = Color(0xFFD97706);
  static const emerald = Color(0xFF16A34A);
  static const red = Color(0xFFDC2626);
}
