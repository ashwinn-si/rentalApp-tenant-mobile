import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.title,
    required this.message,
    required this.targetType,
    required this.expiresAt,
    super.key,
    this.isExpired = false,
  });

  final String title;
  final String message;
  final String targetType;
  final String expiresAt;
  final bool isExpired;

  Widget _buildBadge(bool isDark) {
    final isPersonal = targetType == 'tenant';
    final badgeColor = isPersonal
        ? (isDark ? const Color(0xFFEC4899) : const Color(0xFFDB2777))
        : (isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316));
    final badgeLabel = isPersonal ? 'Personal' : 'Apartment';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        badgeLabel,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF374151).withValues(alpha: 0.5)
        : const Color(0xFFE5E7EB);
    final titleColor = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
    final messageColor =
        isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildBadge(isDark),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: TextStyle(
              color: messageColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
