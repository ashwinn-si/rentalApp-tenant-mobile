import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

enum StateCardVariant { info, error }

class StateCard extends StatelessWidget {
  const StateCard({
    required this.message,
    super.key,
    this.variant = StateCardVariant.info,
  });

  final String message;
  final StateCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final isError = variant == StateCardVariant.error;
    final bgColor = isError ? const Color(0xFFFEE2E2) : const Color(0xFFEDE9FE);
    final textColor = isError ? AppColors.pending : AppColors.violet;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: textColor,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
