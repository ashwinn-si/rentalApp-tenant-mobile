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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = isExpired
        ? (isDark
            ? <Color>[const Color(0xFF525A73), const Color(0xFF3C4357)]
            : <Color>[const Color(0xFF6B7280), const Color(0xFF4B5563)])
        : (isDark
            ? <Color>[const Color(0xFF8B3DFF), const Color(0xFF6B2BD8)]
            : <Color>[const Color(0xFF7C3AED), const Color(0xFF6D28D9)]);

    final titleColor = isDark ? const Color(0xFFF8FAFC) : Colors.white;
    final messageColor =
        isDark ? const Color(0xFFEEF2FF) : Colors.white.withOpacity(0.95);
    final captionColor =
        isDark ? const Color(0xFFD8DBFF) : Colors.white.withOpacity(0.8);

    return Opacity(
      opacity: isExpired ? (isDark ? 0.78 : 0.6) : 1,
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
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(isDark ? 0.32 : 0.25),
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
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Expires: ${formatDate(expiresAt)}',
              style: TextStyle(
                color: captionColor,
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
