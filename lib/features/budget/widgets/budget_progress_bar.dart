import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_color_utils.dart';
import '../../../core/utils/category_icon_utils.dart';
import '../../../core/utils/currency_formatter.dart';

class BudgetProgressBar extends StatelessWidget {
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double budgetAmount;
  final double spentAmount;

  const BudgetProgressBar({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.budgetAmount,
    required this.spentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage =
        budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;

    Color barColor = AppColors.success;
    if (percentage >= 1.0) {
      barColor = AppColors.error;
    } else if (percentage >= 0.8) {
      barColor = AppColors.warning;
    }

    final catColor = CategoryColorUtils.fromHex(categoryColor);
    final catIcon = CategoryIconUtils.fromHex(categoryIcon);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(catIcon, color: catColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(categoryName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '${CurrencyFormatter.formatCompact(spentAmount)} / ${CurrencyFormatter.formatCompact(budgetAmount)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: percentage >= 1.0
                            ? AppColors.error
                            : theme.textTheme.bodySmall?.color,
                        fontWeight: percentage >= 1.0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: theme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
