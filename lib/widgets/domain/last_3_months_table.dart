import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../ui/premium_card.dart';

class Last3MonthsTableItem {
  final String monthLabel;
  final double baseRent;
  final double utility;
  final double maintenance;
  final double totalDue;
  final double paidAmount;
  final double pendingAmount;
  final String status;

  Last3MonthsTableItem({
    required this.monthLabel,
    required this.baseRent,
    required this.utility,
    required this.maintenance,
    required this.totalDue,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
  });
}

class Last3MonthsTable extends StatelessWidget {
  const Last3MonthsTable({
    required this.items,
    super.key,
  });

  final List<Last3MonthsTableItem> items;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.emerald;
      case 'partial':
        return AppColors.orange;
      default:
        return AppColors.red;
    }
  }

  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Rent Comparison',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            DataTable(
              columnSpacing: AppSpacing.md,
              dataTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                  ),
              columns: [
                DataColumn(
                  label: Text(
                    'Month',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Base',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Utility',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Maint.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Total',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Paid',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
              rows: items
                  .map((item) => DataRow(
                        cells: [
                          DataCell(
                            Text(item.monthLabel),
                          ),
                          DataCell(
                            Text(_formatAmount(item.baseRent)),
                            showEditIcon: false,
                          ),
                          DataCell(
                            Text(_formatAmount(item.utility)),
                            showEditIcon: false,
                          ),
                          DataCell(
                            Text(_formatAmount(item.maintenance)),
                            showEditIcon: false,
                          ),
                          DataCell(
                            Text(
                              _formatAmount(item.totalDue),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            showEditIcon: false,
                          ),
                          DataCell(
                            Text(
                              _formatAmount(item.paidAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.emerald,
                              ),
                            ),
                            showEditIcon: false,
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status)
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(item.status),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
