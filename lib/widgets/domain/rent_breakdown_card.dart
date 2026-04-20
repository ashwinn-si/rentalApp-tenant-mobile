import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/currency_formatter.dart';
import '../ui/premium_card.dart';
import '../ui/status_chip.dart';

class RentBreakdownCard extends StatelessWidget {
  const RentBreakdownCard({
    required this.monthLabel,
    required this.status,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenance,
    required this.previousDues,
    required this.totalDue,
    super.key,
    this.paidAmount = 0,
  });

  final String monthLabel;
  final String status;
  final num baseRent;
  final num utilityBill;
  final num maintenance;
  final num previousDues;
  final num totalDue;
  final num paidAmount;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusChip.fromString(status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _row('Base Rent', baseRent),
          _row('Electricity / Water', utilityBill),
          _row('Maintenance', maintenance),
          if (previousDues > 0)
            _row('Previous Dues', previousDues, highlight: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(
              height: 1,
              color: AppColors.textSecondary.withOpacity(0.15),
            ),
          ),
          _row('Total Due', totalDue, bold: true),
          if (paidAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: _row('Paid', paidAmount, paid: true),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, num amount,
      {bool highlight = false, bool bold = false, bool paid = false}) {
    Color color = AppColors.textPrimary;
    if (highlight) {
      color = AppColors.pending;
    } else if (paid) {
      color = AppColors.paid;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(bold ? 1.0 : 0.85),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: bold ? 15 : 14,
            ),
          ),
          Text(
            formatINR(amount),
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
