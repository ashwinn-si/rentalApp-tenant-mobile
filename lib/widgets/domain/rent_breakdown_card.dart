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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? const Color(0xFFF3F4F6) : AppColors.textPrimary;
    final secondaryText =
        isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.violet.withValues(alpha: 0.18),
                          AppColors.violet.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.violet,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    monthLabel,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              StatusChip.fromString(status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _row(
            'Base Rent',
            baseRent,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          _row(
            'Electricity / Water',
            utilityBill,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          _row(
            'Maintenance',
            maintenance,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          if (previousDues > 0)
            _row(
              'Previous Dues',
              previousDues,
              highlight: true,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(
              height: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.15),
            ),
          ),
          _row(
            'Total Due',
            totalDue,
            bold: true,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          if (paidAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: _row(
                'Paid',
                paidAmount,
                paid: true,
                primaryText: primaryText,
                secondaryText: secondaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    num amount, {
    bool highlight = false,
    bool bold = false,
    bool paid = false,
    required Color primaryText,
    required Color secondaryText,
  }) {
    Color color = primaryText;
    if (highlight) {
      color = AppColors.pending;
    } else if (paid) {
      color = AppColors.paid;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: (highlight || paid)
                  ? color
                  : (bold ? primaryText : secondaryText),
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              fontSize: bold ? 15 : 14,
            ),
          ),
          Text(
            formatINR(amount),
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
