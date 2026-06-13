import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

enum RentStatus { paid, partial, pending, error }

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, this.label, super.key});

  final RentStatus status;
  final String? label;

  factory StatusChip.fromString(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'paid') {
      return const StatusChip(status: RentStatus.paid);
    }
    if (normalized == 'partial') {
      return const StatusChip(status: RentStatus.partial);
    }
    if (normalized == 'error' || normalized == 'rejected') {
      return const StatusChip(status: RentStatus.error);
    }
    return const StatusChip(status: RentStatus.pending);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fg;
    final Color lightBg;
    final String defaultLabel;

    switch (status) {
      case RentStatus.paid:
        fg = AppColors.paid;
        lightBg = const Color(0xFFEAFBF4);
        defaultLabel = 'Paid';
      case RentStatus.partial:
        fg = AppColors.partial;
        lightBg = const Color(0xFFFEF6E8);
        defaultLabel = 'Partial';
      case RentStatus.pending:
        fg = AppColors.pending;
        lightBg = const Color(0xFFFFF4DE);
        defaultLabel = 'Pending';
      case RentStatus.error:
        fg = AppColors.red;
        lightBg = const Color(0xFFFEF2F2);
        defaultLabel = 'Error';
    }

    final bg = isDark ? fg.withValues(alpha: 0.15) : lightBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: fg.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label ?? defaultLabel,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
