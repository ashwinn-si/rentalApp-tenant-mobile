import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/currency_formatter.dart';
import 'premium_card.dart';

Color _lighten(Color color, [double amount = 0.16]) {
  return Color.lerp(color, Colors.white, amount) ?? color;
}

class RentBarItem {
  const RentBarItem({
    required this.monthLabel,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenance,
  });

  final String monthLabel;
  final num baseRent;
  final num utilityBill;
  final num maintenance;

  double get total =>
      baseRent.toDouble() + utilityBill.toDouble() + maintenance.toDouble();
}

class RentLineItem {
  const RentLineItem({
    required this.monthLabel,
    required this.due,
    required this.paid,
  });

  final String monthLabel;
  final num due;
  final num paid;
}

class RentPercentageTable extends StatelessWidget {
  const RentPercentageTable({required this.data, super.key});

  final List<RentBarItem> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final headerColor = isDark ? const Color(0xFFE5E7EB) : AppColors.textSecondary;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.textSecondary.withValues(alpha: 0.1);

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScaleInAnimation(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
            (_) => isDark ? const Color(0xFF2A2540) : AppColors.violet.withValues(alpha: 0.08),
          ),
          headingRowHeight: 48,
          dataRowHeight: 52,
          columnSpacing: AppSpacing.lg,
          border: TableBorder(
            horizontalInside: BorderSide(color: borderColor, width: 0.5),
            bottom: BorderSide(color: borderColor, width: 0.5),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Month',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Rent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Base Rent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Utility Bill',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Maintenance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                ),
              ),
            ),
          ],
          rows: data.map((item) {
            final total = item.total;
            final baseRentPct = total > 0 ? ((item.baseRent.toDouble() / total) * 100).toStringAsFixed(1) : '0.0';
            final utilityPct = total > 0 ? ((item.utilityBill.toDouble() / total) * 100).toStringAsFixed(1) : '0.0';
            final maintenancePct = total > 0 ? ((item.maintenance.toDouble() / total) * 100).toStringAsFixed(1) : '0.0';

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    _compactMonthLabel(item.monthLabel),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    formatINR(item.total),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '$baseRentPct%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.violet,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '$utilityPct%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '$maintenancePct%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _compactMonthLabel(String input) {
    final parts = input.trim().split(' ');
    if (parts.length < 2) return input;
    final month = parts.first;
    final year = parts.last;
    final shortMonth = month.length > 3 ? month.substring(0, 3) : month;
    return '$shortMonth $year';
  }

}

class RentTrendLineChart extends StatelessWidget {
  const RentTrendLineChart({required this.data, super.key});

  final List<RentLineItem> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScaleInAnimation(
      duration: AppAnimations.slow,
      child: PremiumCard(
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.due.toDouble(),
                              ))
                          .toList(),
                      color: AppColors.violet,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.violet,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.violet.withValues(alpha: 0.15),
                            AppColors.violet.withValues(alpha: 0.01),
                          ],
                        ),
                      ),
                    ),
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.paid.toDouble(),
                              ))
                          .toList(),
                      color: AppColors.paid,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.paid,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.paid.withValues(alpha: 0.15),
                            AppColors.paid.withValues(alpha: 0.01),
                          ],
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              data[idx].monthLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.textSecondary.withValues(alpha: 0.08),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final legendTextColor =
        isDark ? const Color(0xFFE5E7EB) : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Due', AppColors.violet, legendTextColor),
        const SizedBox(width: AppSpacing.lg),
        _buildLegendItem('Paid', AppColors.paid, legendTextColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class BreakdownItem {
  const BreakdownItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final num amount;
  final Color color;
}

class RentBreakdownPieChart extends StatefulWidget {
  const RentBreakdownPieChart({
    required this.items,
    this.monthLabel,
    super.key,
  });

  final List<BreakdownItem> items;
  final String? monthLabel;

  @override
  State<RentBreakdownPieChart> createState() => _RentBreakdownPieChartState();
}

class _RentBreakdownPieChartState extends State<RentBreakdownPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor =
        isDark ? const Color(0xFFF9FAFB) : AppColors.textPrimary;
    final legendTextColor =
        isDark ? const Color(0xFFE5E7EB) : AppColors.textSecondary;
    final valueTextColor =
        isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;

    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScaleInAnimation(
      duration: AppAnimations.slow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rent Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: headingColor,
            ),
          ),
          if (widget.monthLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.monthLabel!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: legendTextColor,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                sectionsSpace: isDark ? 1.2 : 2,
                centerSpaceRadius: 56,
                centerSpaceColor:
                    isDark ? const Color(0xFF25213B) : Colors.white,
                sections: widget.items.asMap().entries.map(
                  (entry) {
                    final sectionColor = isDark
                        ? _lighten(entry.value.color, 0.2)
                        : entry.value.color;

                    return PieChartSectionData(
                      value: entry.value.amount.toDouble(),
                      color: sectionColor,
                      radius: _touchedIndex == entry.key ? 88 : 82,
                      borderSide: BorderSide(
                        color: sectionColor,
                        width: isDark ? 0.6 : 0,
                      ),
                      title: '',
                    );
                  },
                ).toList(),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      _touchedIndex = pieTouchResponse
                              ?.touchedSection?.touchedSectionIndex ??
                          -1;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            children: widget.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: legendTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          formatINR(item.amount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: valueTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
