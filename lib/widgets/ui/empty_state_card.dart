import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

enum EmptyStateType {
  paymentProof,
  documents,
  maintenance,
  notifications,
  history,
  generic,
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    required this.type,
    this.title,
    this.message,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  IconData _getIcon() {
    switch (type) {
      case EmptyStateType.paymentProof:
        return Icons.receipt_outlined;
      case EmptyStateType.documents:
        return Icons.description_outlined;
      case EmptyStateType.maintenance:
        return Icons.build_circle_outlined;
      case EmptyStateType.notifications:
        return Icons.notifications_outlined;
      case EmptyStateType.history:
        return Icons.history_outlined;
      case EmptyStateType.generic:
        return Icons.info_outline;
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case EmptyStateType.paymentProof:
        return 'No Payment Proofs';
      case EmptyStateType.documents:
        return 'No Documents';
      case EmptyStateType.maintenance:
        return 'No Issues Reported';
      case EmptyStateType.notifications:
        return 'No Notifications';
      case EmptyStateType.history:
        return 'No History';
      case EmptyStateType.generic:
        return 'No Data';
    }
  }

  String _getDefaultMessage() {
    switch (type) {
      case EmptyStateType.paymentProof:
        return 'You haven\'t submitted any payment proofs yet';
      case EmptyStateType.documents:
        return 'You haven\'t uploaded any documents yet';
      case EmptyStateType.maintenance:
        return 'No maintenance issues have been reported yet';
      case EmptyStateType.notifications:
        return 'You don\'t have any notifications right now';
      case EmptyStateType.history:
        return 'No rent history available';
      case EmptyStateType.generic:
        return 'No data available';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark
        ? const Color(0xFF10B981).withValues(alpha: 0.2)
        : const Color(0xFF10B981).withValues(alpha: 0.15);
    final iconColor = isDark
        ? const Color(0xFF10B981)
        : const Color(0xFF10B981);
    final titleColor = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
    final messageColor =
        isDark ? const Color(0xFFA3A3A3) : AppColors.textSecondary;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
        // Decorative icon container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIcon(),
            size: 40,
            color: iconColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title ?? _getDefaultTitle(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message ?? _getDefaultMessage(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: messageColor,
            height: 1.5,
          ),
        ),
        if (actionLabel != null && onActionPressed != null) ...[
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onActionPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                foregroundColor: AppColors.violet,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
        ),
      );
  }
}
