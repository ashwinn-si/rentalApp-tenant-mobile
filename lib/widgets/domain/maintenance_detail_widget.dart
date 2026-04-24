import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/history/data/models/history_response.dart';

class MaintenanceDetailWidget extends StatefulWidget {
  const MaintenanceDetailWidget({
    required this.items,
    required this.total,
    super.key,
  });

  final List<MaintenanceBreakdownItem> items;
  final num total;

  @override
  State<MaintenanceDetailWidget> createState() => _MaintenanceDetailWidgetState();
}

class _MaintenanceDetailWidgetState extends State<MaintenanceDetailWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? const Color(0xFFF3F4F6) : AppColors.textPrimary;
    final secondaryText =
        isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;

    return Column(
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.violet.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Maintenance Breakdown (${widget.items.length} ${widget.items.length == 1 ? 'item' : 'items'})',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: AppAnimations.fast,
                  child: Icon(
                    Icons.expand_more,
                    color: AppColors.violet,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          AnimatedSize(
            duration: AppAnimations.normal,
            curve: AppAnimations.easeOutCubic,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                ...widget.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isLast = entry.key == widget.items.length - 1;
                  final sign = item.type == 'reimbursement' ? '-' : '+';
                  final signColor = item.type == 'reimbursement'
                      ? AppColors.pending
                      : AppColors.paid;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                          horizontal: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.type == 'reimbursement'
                                        ? 'Reimbursement'
                                        : 'Adjustment',
                                    style: TextStyle(
                                      color: secondaryText.withValues(alpha: 0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  sign,
                                  style: TextStyle(
                                    color: signColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  formatINR(item.amount),
                                  style: TextStyle(
                                    color: signColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Divider(
                            height: 1,
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}
