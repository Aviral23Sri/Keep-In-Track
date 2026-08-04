import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/reports_providers.dart';

class IncomeExpenseBarChart extends StatefulWidget {
  final List<WeekBucket> buckets;

  const IncomeExpenseBarChart({super.key, required this.buckets});

  @override
  State<IncomeExpenseBarChart> createState() => _IncomeExpenseBarChartState();
}

class _IncomeExpenseBarChartState extends State<IncomeExpenseBarChart> {
  int _touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate max for interval
    double maxVal = 0;
    for (final b in widget.buckets) {
      if (b.income > maxVal) maxVal = b.income;
      if (b.expense > maxVal) maxVal = b.expense;
    }
    final interval = maxVal == 0 ? 1000.0 : (maxVal / 4).ceilToDouble();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Text(
                  'Income vs Expense',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                _Legend(color: AppColors.income, label: 'Income'),
                const SizedBox(width: 12),
                _Legend(color: AppColors.expense, label: 'Expense'),
              ],
            ),
          ),

          // ── Chart ────────────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: BarChart(
                BarChartData(
                  maxY: maxVal == 0 ? 1000 : maxVal * 1.2,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchCallback: (FlTouchEvent event, response) {
                      setState(() {
                        if (response?.spot == null ||
                            event is FlPointerExitEvent ||
                            event is FlTapUpEvent) {
                          _touchedGroupIndex = -1;
                        } else {
                          _touchedGroupIndex =
                              response!.spot!.touchedBarGroupIndex;
                        }
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                      tooltipRoundedRadius: 12,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final bucket = widget.buckets[groupIndex];
                        final isIncome = rodIndex == 0;
                        return BarTooltipItem(
                          '${isIncome ? "Income" : "Expense"}\n${NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹').format(isIncome ? bucket.income : bucket.expense)}',
                          TextStyle(
                            color: isIncome ? AppColors.income : AppColors.expense,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= widget.buckets.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              widget.buckets[idx].label,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            NumberFormat.compact().format(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(widget.buckets.length, (i) {
                    final b = widget.buckets[i];
                    final isTouched = i == _touchedGroupIndex;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: b.income,
                          color: isTouched
                              ? AppColors.income
                              : AppColors.income.withValues(alpha: 0.75),
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                        BarChartRodData(
                          toY: b.expense,
                          color: isTouched
                              ? AppColors.expense
                              : AppColors.expense.withValues(alpha: 0.75),
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
