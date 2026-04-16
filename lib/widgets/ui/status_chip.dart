import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

enum RentStatus { paid, partial, pending }

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final RentStatus status;

  factory StatusChip.fromString(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'paid') {
      return const StatusChip(status: RentStatus.paid);
    }
    if (normalized == 'partial') {
      return const StatusChip(status: RentStatus.partial);
    }
    return const StatusChip(status: RentStatus.pending);
  }

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final Color bg;
    final String label;

    switch (status) {
      case RentStatus.paid:
        fg = AppColors.paid;
        bg = const Color(0xFFDCFCE7);
        label = 'Paid';
      case RentStatus.partial:
        fg = AppColors.partial;
        bg = const Color(0xFFFEF3C7);
        label = 'Partial';
      case RentStatus.pending:
        fg = AppColors.pending;
        bg = const Color(0xFFFEE2E2);
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
