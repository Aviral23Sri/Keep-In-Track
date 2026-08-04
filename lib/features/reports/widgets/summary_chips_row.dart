import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class SummaryChipsRow extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double avgDailySpend;

  const SummaryChipsRow({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.avgDailySpend,
  });

  @override
  Widget build(BuildContext context) {
    final net = totalIncome - totalExpense;
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _Chip(
            label: 'Income',
            amount: totalIncome,
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(width: 12),
          _Chip(
            label: 'Expense',
            amount: totalExpense,
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
          const SizedBox(width: 12),
          _Chip(
            label: 'Net',
            amount: net,
            color: net >= 0 ? AppColors.success : AppColors.error,
            icon: net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          ),
          const SizedBox(width: 12),
          _Chip(
            label: 'Avg/Day',
            amount: avgDailySpend,
            color: AppColors.warning,
            icon: Icons.today_rounded,
          ),
          const SizedBox(width: 12),
          _Chip(
            label: 'Savings',
            amount: totalSavings,
            color: AppColors.savings,
            icon: Icons.savings_rounded,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _Chip({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            CurrencyFormatter.formatCompact(amount.abs()),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
