import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/app_constants.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String gradientName;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.gradientName,
    required this.icon,
  });

  LinearGradient _getGradient(bool isDark) {
    if (isDark) return AppColors.darkCardGradient;

    switch (gradientName) {
      case 'income':
        return AppColors.incomeGradient;
      case 'expense':
        return AppColors.expenseGradient;
      case 'savings':
        return AppColors.savingsGradient;
      default:
        return AppColors.balanceGradient;
    }
  }

  Color _getIconColor(bool isDark) {
    if (!isDark) return Colors.white;
    switch (gradientName) {
      case 'income':
        return AppColors.income;
      case 'expense':
        return AppColors.expense;
      case 'savings':
        return AppColors.savings;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = _getGradient(isDark);
    final iconColor = _getIconColor(isDark);
    const textColor = Colors.white; // Or could depend on theme if needed

    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          AnimatedCounter(
            value: amount,
            formatter: (v) => CurrencyFormatter.format(v),
            style: AppTextStyles.amountLarge().copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
