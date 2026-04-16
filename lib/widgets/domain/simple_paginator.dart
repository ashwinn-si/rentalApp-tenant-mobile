import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ElevatedButton.icon(
          onPressed: page <= 1 ? null : onPrev,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Prev'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet, foregroundColor: Colors.white),
        ),
        Text('Page $page of $totalPages',
            style: const TextStyle(color: AppColors.textSecondary)),
        ElevatedButton.icon(
          onPressed: page >= totalPages ? null : onNext,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text('Next'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet, foregroundColor: Colors.white),
        ),
      ],
    );
  }
}
