import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/history/data/models/history_response.dart';
import '../../features/maintenance_issues/screens/issue_detail_by_id_screen.dart';
import '../ui/premium_card.dart';
import '../ui/status_chip.dart';

class RentBreakdownCard extends StatefulWidget {
  const RentBreakdownCard({
    required this.monthLabel,
    required this.status,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenance,
    required this.previousDues,
    required this.totalDue,
    super.key,
    this.flatLabel = '',
    this.paidAmount = 0,
    this.maintenanceBreakdownItems = const <MaintenanceBreakdownItem>[],
  });

  final String monthLabel;
  final String flatLabel;
  final String status;
  final num baseRent;
  final num utilityBill;
  final num maintenance;
  final num previousDues;
  final num totalDue;
  final num paidAmount;
  final List<MaintenanceBreakdownItem> maintenanceBreakdownItems;

  @override
  State<RentBreakdownCard> createState() => _RentBreakdownCardState();
}

class _RentBreakdownCardState extends State<RentBreakdownCard> {
  bool _breakdownExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF3F4F6) : AppColors.textPrimary;
    final secondaryText = isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;
    final dividerColor = AppColors.textSecondary.withValues(alpha: 0.12);

    final balanceDue = (widget.totalDue - widget.paidAmount).clamp(0, double.infinity) as num;
    final isFullyPaid = balanceDue == 0;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.monthLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (widget.flatLabel.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.flatLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StatusChip.fromString(widget.status),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: AppSpacing.sm),

          // ── Line items ───────────────────────────────────────
          _lineRow('Base Rent', widget.baseRent, secondaryText: secondaryText, primaryText: primaryText),
          _lineRow('Electricity / Water', widget.utilityBill, secondaryText: secondaryText, primaryText: primaryText),
          _maintenanceRow(secondaryText: secondaryText, primaryText: primaryText, dividerColor: dividerColor),

          if (widget.previousDues > 0)
            _lineRow(
              'Previous Dues',
              widget.previousDues,
              secondaryText: secondaryText,
              primaryText: primaryText,
              amountColor: AppColors.pending,
            ),

          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: AppSpacing.sm),

          // ── Total to Pay ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total to Pay',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primaryText),
              ),
              Text(
                formatINR(widget.totalDue),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.violet),
              ),
            ],
          ),

          // ── Paid ─────────────────────────────────────────────
          if (widget.paidAmount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.paid)),
                Text(
                  '− ${formatINR(widget.paidAmount)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.paid),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: AppSpacing.sm),

          // ── Balance Due ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance Due',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primaryText),
              ),
              Text(
                formatINR(balanceDue),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isFullyPaid ? AppColors.paid : AppColors.pending,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineRow(
    String label,
    num amount, {
    required Color secondaryText,
    required Color primaryText,
    Color? amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondaryText)),
          Text(
            formatINR(amount),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: amountColor ?? secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _maintenanceRow({
    required Color secondaryText,
    required Color primaryText,
    required Color dividerColor,
  }) {
    final isCredit = widget.maintenance < 0;
    final displayAmount = widget.maintenance.abs();
    final amountColor = isCredit ? AppColors.paid : secondaryText;
    final hasBreakdown = widget.maintenanceBreakdownItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main maintenance row — tappable if breakdown exists
        GestureDetector(
          onTap: hasBreakdown ? () => setState(() => _breakdownExpanded = !_breakdownExpanded) : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Maintenance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondaryText)),
                    if (hasBreakdown) ...[
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _breakdownExpanded ? 0.5 : 0,
                        duration: AppAnimations.fast,
                        child: Icon(Icons.expand_more, size: 16, color: AppColors.violet),
                      ),
                    ],
                  ],
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: isCredit ? '− ${formatINR(displayAmount)}' : formatINR(displayAmount),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: amountColor),
                      ),
                      if (isCredit)
                        TextSpan(
                          text: '  (Credit)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.paid),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Collapsible breakdown
        if (hasBreakdown)
          AnimatedSize(
            duration: AppAnimations.normal,
            curve: AppAnimations.easeOutCubic,
            child: _breakdownExpanded
                ? Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.violet.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.violet.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: widget.maintenanceBreakdownItems.asMap().entries.map((entry) {
                        final item = entry.value;
                        final isLast = entry.key == widget.maintenanceBreakdownItems.length - 1;
                        final isReimbursement = item.type == 'reimbursement';
                        final sign = isReimbursement ? '−' : '+';
                        final signColor = isReimbursement ? AppColors.pending : AppColors.paid;
                        final hasLink = item.issueId != null && item.issueId!.isNotEmpty;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: hasLink
                                        ? GestureDetector(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder: (_) => IssueDetailByIdScreen(issueId: item.issueId!),
                                              ),
                                            ),
                                            child: Text(
                                              'Issue Reimbursement (#${item.issueId})',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.violet,
                                                decoration: TextDecoration.underline,
                                                decorationColor: AppColors.violet,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            item.name,
                                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$sign ${formatINR(item.yourShare)}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: signColor),
                                        ),
                                        if (item.totalCost > 0)
                                          TextSpan(
                                            text: ' of ${formatINR(item.totalCost)}',
                                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(height: 1, color: dividerColor),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
