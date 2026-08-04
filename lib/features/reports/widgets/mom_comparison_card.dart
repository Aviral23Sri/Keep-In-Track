import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/providers/reports_providers.dart';

class MomComparisonCard extends StatelessWidget {
  final MoMComparison mom;
  final DateTime currentMonth;

  const MomComparisonCard({
    super.key,
    required this.mom,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prevMonth =
        DateTime(currentMonth.year, currentMonth.month - 1, 1);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'vs Last Month',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${DateFormat('MMM').format(prevMonth)} → ${DateFormat('MMM').format(currentMonth)}',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DeltaTile(
                  label: 'Expense',
                  current: mom.currentExpense,
                  previous: mom.previousExpense,
                  delta: mom.expenseDelta,
                  pct: mom.expenseChangePercent,
                  isBetter: mom.isExpenseBetter,
                  betterColor: AppColors.success,
                  worseColor: AppColors.error,
                  icon: Icons.arrow_upward_rounded,
                  baseColor: AppColors.expense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DeltaTile(
                  label: 'Income',
                  current: mom.currentIncome,
                  previous: mom.previousIncome,
                  delta: mom.incomeDelta,
                  pct: mom.incomeChangePercent,
                  isBetter: mom.isIncomeBetter,
                  betterColor: AppColors.success,
                  worseColor: AppColors.error,
                  icon: Icons.arrow_downward_rounded,
                  baseColor: AppColors.income,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeltaTile extends StatelessWidget {
  final String label;
  final double current;
  final double previous;
  final double delta;
  final double pct;
  final bool isBetter;
  final Color betterColor;
  final Color worseColor;
  final IconData icon;
  final Color baseColor;

  const _DeltaTile({
    required this.label,
    required this.current,
    required this.previous,
    required this.delta,
    required this.pct,
    required this.isBetter,
    required this.betterColor,
    required this.worseColor,
    required this.icon,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = isBetter ? betterColor : worseColor;
    final sign = delta > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: baseColor),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.formatCompact(current),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: baseColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isBetter ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                size: 13,
                color: statusColor,
              ),
              const SizedBox(width: 3),
              Text(
                '$sign${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          Text(
            'prev: ${CurrencyFormatter.formatCompact(previous)}',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
