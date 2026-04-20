import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class InfoField extends StatelessWidget {
  const InfoField({required this.label, this.value, super.key});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final displayValue =
        (value == null || value!.trim().isEmpty) ? '-' : value!;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF9FAFB),
            const Color(0xFFF3F4F6).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.violet.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          ...AppShadows.card(),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
