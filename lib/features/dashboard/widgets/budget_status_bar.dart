import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/providers/budget_providers.dart';
import '../../../shared/providers/reports_providers.dart';

class BudgetStatusBar extends ConsumerWidget {
  const BudgetStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(currentMonthBudgetsProvider);
    final reportAsync = ref.watch(reportDataProvider(ReportPeriod.monthly));
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: budgetsAsync.when(
        data: (budgets) {
          final overallBudget = budgets
              .cast<dynamic>()
              .firstWhere((b) => b.isOverall, orElse: () => null);
          if (overallBudget == null) {
            return const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondaryLight),
                SizedBox(width: 12),
                Expanded(child: Text('No overall budget set for this month.')),
              ],
            );
          }

          return reportAsync.when(
            data: (report) {
              final spent = report.totalExpense;
              final limit = overallBudget.amount;
              final percentage = (spent / limit).clamp(0.0, 1.0);
              final remaining = limit - spent;
              final daysLeft = DateFormatter.daysRemainingInMonth();

              Color barColor = AppColors.success;
              if (percentage >= 1.0) {
                barColor = AppColors.error;
              } else if (percentage >= 0.8) {
                barColor = AppColors.warning;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Budget',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        percentage >= 1.0
                            ? "Over budget"
                            : "${CurrencyFormatter.format(remaining)} left",
                        style: TextStyle(
                          color: barColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 12,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${CurrencyFormatter.formatCompact(spent)} of ${CurrencyFormatter.formatCompact(limit)}',
                        style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12),
                      ),
                      Text(
                        '$daysLeft days left',
                        style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}
