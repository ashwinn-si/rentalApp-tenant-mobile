import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/currency_formatter.dart';
import 'premium_card.dart';

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

class RentStackedBarChart extends StatelessWidget {
  const RentStackedBarChart({required this.data, super.key});

  final List<RentBarItem> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScaleInAnimation(
      child: PremiumCard(
        child: SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              barGroups: data
                  .asMap()
                  .entries
                  .map(
                    (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: entry.value.total,
                          width: 18,
                          color: Colors.transparent,
                          rodStackItems: [
                            BarChartRodStackItem(
                              0,
                              entry.value.baseRent.toDouble(),
                              AppColors.violet,
                            ),
                            BarChartRodStackItem(
                              entry.value.baseRent.toDouble(),
                              entry.value.baseRent.toDouble() +
                                  entry.value.utilityBill.toDouble(),
                              const Color(0xFF06B6D4),
                            ),
                            BarChartRodStackItem(
                              entry.value.baseRent.toDouble() +
                                  entry.value.utilityBill.toDouble(),
                              entry.value.total,
                              const Color(0xFFF59E0B),
                            ),
                          ],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: _getMaxValue(),
                            color: AppColors.violet.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
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
                          color: AppColors.textSecondary.withOpacity(0.6),
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
                            color: AppColors.textSecondary.withOpacity(0.7),
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
                horizontalInterval: _getMaxValue() / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withOpacity(0.08),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    width: 1,
                  ),
                  left: BorderSide(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxValue() {
    if (data.isEmpty) {
      return 0;
    }
    return data
            .map((item) => item.total.toDouble())
            .reduce((a, b) => a > b ? a : b) *
        1.2;
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
                            AppColors.violet.withOpacity(0.15),
                            AppColors.violet.withOpacity(0.01),
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
                            AppColors.paid.withOpacity(0.15),
                            AppColors.paid.withOpacity(0.01),
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
                              color: AppColors.textSecondary.withOpacity(0.6),
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
                                color: AppColors.textSecondary.withOpacity(0.7),
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
                        color: AppColors.textSecondary.withOpacity(0.08),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Due', AppColors.violet),
        const SizedBox(width: AppSpacing.lg),
        _buildLegendItem('Paid', AppColors.paid),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
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
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
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
    super.key,
  });

  final List<BreakdownItem> items;

  @override
  State<RentBreakdownPieChart> createState() => _RentBreakdownPieChartState();
}

class _RentBreakdownPieChartState extends State<RentBreakdownPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScaleInAnimation(
      duration: AppAnimations.slow,
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rent Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: widget.items
                      .asMap()
                      .entries
                      .map(
                        (entry) => PieChartSectionData(
                          value: entry.value.amount.toDouble(),
                          color: entry.value.color,
                          radius: _touchedIndex == entry.key ? 65 : 60,
                          title: '',
                        ),
                      )
                      .toList(),
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
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            formatINR(item.amount),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
      ),
    );
  }
}
