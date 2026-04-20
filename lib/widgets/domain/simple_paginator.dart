import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../ui/premium_card.dart';

class SimplePaginator extends StatelessWidget {
  const SimplePaginator({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
    super.key,
  });

  final int page;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: page <= 1 ? null : onPrev,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Prev'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.violet,
              side: BorderSide(
                color: AppColors.violet.withValues(alpha: 0.25),
              ),
            ),
          ),
          Text(
            'Page $page of $totalPages',
            style: TextStyle(
              color: isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton.icon(
            onPressed: page >= totalPages ? null : onNext,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
