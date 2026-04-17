import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/date_formatter.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = isExpired
        ? <Color>[const Color(0xFF6B7280), const Color(0xFF4B5563)]
        : <Color>[const Color(0xFF7C3AED), const Color(0xFF6D28D9)];

    return Opacity(
      opacity: isExpired ? 0.6 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Expires: ${formatDate(expiresAt)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
