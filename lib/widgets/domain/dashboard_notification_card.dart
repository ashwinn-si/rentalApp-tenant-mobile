import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';

class DashboardNotificationCard extends StatelessWidget {
  const DashboardNotificationCard({
    required this.notificationCount,
    required this.latestTitle,
    required this.latestMessage,
    super.key,
  });

  final int notificationCount;
  final String latestTitle;
  final String latestMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF7C3AED) : AppColors.violet;
    final cardBg = isDark ? bgColor.withValues(alpha: 0.95) : bgColor;
    final textColor = Colors.white;
    final subTextColor = Colors.white.withValues(alpha: 0.9);

    return GestureDetector(
      onTap: () => context.go('/notifications'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardBg,
              cardBg.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: isDark ? 0.3 : 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: textColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '$notificationCount notification${notificationCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: textColor.withValues(alpha: 0.7),
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              latestTitle,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              latestMessage,
              style: TextStyle(
                color: subTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
