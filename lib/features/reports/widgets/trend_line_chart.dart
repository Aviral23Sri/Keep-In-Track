import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/providers/reports_providers.dart';

class TrendLineChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final ReportPeriod period;

  const TrendLineChart({super.key, required this.transactions, required this.period});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group transactions by day
    final Map<int, double> expensesByDay = {};
    final Map<int, double> incomeByDay = {};
    
    int minDay = 31;
    int maxDay = 1;

    for (final t in transactions) {
      final day = t.date.day;
      if (day < minDay) minDay = day;
      if (day > maxDay) maxDay = day;

      if (t.type == 'expense') {
        expensesByDay[day] = (expensesByDay[day] ?? 0) + t.amount;
      } else if (t.type == 'income') {
        incomeByDay[day] = (incomeByDay[day] ?? 0) + t.amount;
      }
    }

    if (minDay > maxDay) return const SizedBox(); // No valid dates

    final List<FlSpot> expenseSpots = [];
    final List<FlSpot> incomeSpots = [];
    
    for (int i = minDay; i <= maxDay; i++) {
      expenseSpots.add(FlSpot(i.toDouble(), expensesByDay[i] ?? 0));
      incomeSpots.add(FlSpot(i.toDouble(), incomeByDay[i] ?? 0));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 16, left: 8, top: 24, bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1000, // Customize based on data scale
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: period == ReportPeriod.monthly ? 5 : 1,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1000,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  return Text(
                    NumberFormat.compact().format(value),
                    style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: minDay.toDouble(),
          maxX: maxDay.toDouble(),
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: AppColors.income,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.income.withOpacity(0.1),
              ),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: AppColors.expense,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.expense.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
