import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/reports_providers.dart';
import '../../core/utils/category_color_utils.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import 'widgets/budget_progress_bar.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(currentMonthBudgetsProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);
    final reportAsync = ref.watch(reportDataProvider(ReportPeriod.monthly));

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () => _showSetOverallBudgetDialog(context, ref),
            tooltip: 'Set Overall Budget',
          ),
        ],
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          final overallBudget = budgets
              .cast<dynamic>()
              .firstWhere((b) => b.isOverall, orElse: () => null);

          return reportAsync.when(
            data: (report) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildOverallBudgetSection(
                      context, overallBudget, report.totalExpense),
                  const SizedBox(height: 32),
                  const Text('Category Budgets',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  categoriesAsync.when(
                    data: (categories) {
                      final expenseCategories =
                          categories.where((c) => c.type == 'expense').toList();
                      return Column(
                        children: expenseCategories.map((cat) {
                          final b = budgets.cast<dynamic>().firstWhere(
                              (b) => b.categoryId == cat.id,
                              orElse: () => null);
                          final spent =
                              report.expensesByCategory[cat.id] ?? 0.0;

                          return InkWell(
                            onTap: () => _showSetCategoryBudgetDialog(
                                context, ref, cat, b),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              child: b == null
                                  ? Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: CategoryColorUtils.fromHex(cat.color)
                                                .withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                              CategoryIconUtils.fromHex(cat.icon),
                                              color: CategoryColorUtils.fromHex(cat.color),
                                              size: 20),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(cat.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        Text('Set Limit',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary)),
                                      ],
                                    )
                                  : BudgetProgressBar(
                                      categoryName: cat.name,
                                      categoryIcon: cat.icon,
                                      categoryColor: cat.color,
                                      budgetAmount: b.amount,
                                      spentAmount: spent,
                                    ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildOverallBudgetSection(
      BuildContext context, BudgetModel? overallBudget, double totalSpent) {
    final theme = Theme.of(context);
    if (overallBudget == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: const Column(
          children: [
            Icon(Icons.account_balance_wallet,
                size: 48, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'No Overall Budget Set',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Set a monthly spending limit to track your overall progress.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final limit = overallBudget.amount;
    final percentage = (totalSpent / limit).clamp(0.0, 1.0);

    Color color = AppColors.success;
    if (percentage >= 1.0) {
      color = AppColors.error;
    } else if (percentage >= 0.8) color = AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${DateTime.now().year} - ${DateFormatter.formatShort(DateTime.now()).split(' ')[1]}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percentage),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 16,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Text('Spent', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent',
                      style: TextStyle(color: AppColors.textSecondaryLight)),
                  Text(CurrencyFormatter.format(totalSpent),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Budget',
                      style: TextStyle(color: AppColors.textSecondaryLight)),
                  Text(CurrencyFormatter.format(limit),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetOverallBudgetDialog(BuildContext context, WidgetRef ref) {
    String amount = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Overall Monthly Budget'),
        content: TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₹)'),
          onChanged: (val) => amount = val,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(amount);
              if (val != null && val > 0) {
                final now = DateTime.now();
                final budget = BudgetModel(
                  id: const Uuid().v4(),
                  amount: val,
                  month: now.month,
                  year: now.year,
                  categoryId: null, // null categoryId means overall budget
                );
                ref
                    .read(budgetsControllerProvider.notifier)
                    .addOrUpdateBudget(budget);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSetCategoryBudgetDialog(BuildContext context, WidgetRef ref,
      CategoryModel cat, BudgetModel? existing) {
    String amount = existing?.amount.toString() ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget: ${cat.name}'),
        content: TextField(
          controller: TextEditingController(text: amount),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₹)'),
          onChanged: (val) => amount = val,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          if (existing != null)
            TextButton(
              onPressed: () {
                ref
                    .read(budgetsControllerProvider.notifier)
                    .deleteBudget(existing.id);
                Navigator.pop(context);
              },
              child: const Text('Remove',
                  style: TextStyle(color: AppColors.error)),
            ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(amount);
              if (val != null && val > 0) {
                final now = DateTime.now();
                final budget = BudgetModel(
                  id: existing?.id ?? const Uuid().v4(),
                  amount: val,
                  month: now.month,
                  year: now.year,
                  categoryId: cat.id,
                );
                ref
                    .read(budgetsControllerProvider.notifier)
                    .addOrUpdateBudget(budget);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
