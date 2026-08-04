import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../core/utils/category_color_utils.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../shared/providers/reports_providers.dart';
import 'widgets/budget_progress_bar.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(budgetPeriodProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Budget')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Period Tabs ──────────────────────────────────────────────────
          _PeriodTabs(selected: selectedPeriod),
          const SizedBox(height: 24),

          // ── Overall Budget Card ───────────────────────────────────────────
          _OverallBudgetCard(period: selectedPeriod),
          const SizedBox(height: 32),

          // ── Category Budgets ────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  '${selectedPeriod[0].toUpperCase()}${selectedPeriod.substring(1)} Category Limits',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Tap to set',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CategoryBudgetList(period: selectedPeriod),
        ],
      ),
    );
  }
}

// ── Period Tab Selector ────────────────────────────────────────────────────────

class _PeriodTabs extends ConsumerWidget {
  final String selected;
  const _PeriodTabs({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final periods = ['daily', 'weekly', 'monthly'];
    final labels = ['Daily', 'Weekly', 'Monthly'];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: List.generate(periods.length, (i) {
          final isSelected = periods[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(budgetPeriodProvider.notifier).state = periods[i],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Overall Budget Card ────────────────────────────────────────────────────────

class _OverallBudgetCard extends ConsumerWidget {
  final String period;
  const _OverallBudgetCard({required this.period});

  String _periodLabel(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'daily':
        return DateFormatter.formatShort(now);
      case 'weekly':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return '${DateFormatter.formatShort(monday)} – ${DateFormatter.formatShort(sunday)}';
      default:
        return DateFormatter.formatMonthYear(now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(currentMonthBudgetsProvider);
    final theme = Theme.of(context);

    // Get the right spend provider
    final AsyncValue<double> spendAsync;
    switch (period) {
      case 'daily':
        spendAsync = ref.watch(dailySpendProvider);
        break;
      case 'weekly':
        spendAsync = ref.watch(weeklySpendProvider);
        break;
      default:
        spendAsync = ref.watch(monthlySpendProvider);
    }

    return budgetsAsync.when(
      data: (budgets) {
        final existingBudget = budgets.cast<dynamic>().firstWhere(
            (b) => b.isOverall && b.period == period, orElse: () => null);
        final budget = existingBudget?.amount;
        
        final totalSpent = spendAsync.maybeWhen(data: (v) => v, orElse: () => 0.0);

        if (budget == null) {
          return _buildNoBudgetCard(context, ref, period);
        }

        final percentage = (totalSpent / budget).clamp(0.0, 1.0);
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
                color: color.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _periodLabel(period),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                    onPressed: () => _showSetBudgetDialog(context, ref, period, existingBudget),
                    tooltip: 'Edit budget',
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                      Text(CurrencyFormatter.format(budget),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildNoBudgetCard(BuildContext context, WidgetRef ref, String period) {
    final theme = Theme.of(context);
    String periodLabel;
    switch (period) {
      case 'daily': periodLabel = 'Daily'; break;
      case 'weekly': periodLabel = 'Weekly'; break;
      default: periodLabel = 'Monthly';
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'No $periodLabel Budget Set',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a $periodLabel spending limit to track your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                _showSetBudgetDialog(context, ref, period, null),
            icon: const Icon(Icons.add),
            label: Text('Set $periodLabel Budget'),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref,
      String period, BudgetModel? existing) {
    final controller = TextEditingController(
        text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    String periodLabel;
    switch (period) {
      case 'daily': periodLabel = 'Daily'; break;
      case 'weekly': periodLabel = 'Weekly'; break;
      default: periodLabel = 'Monthly';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set $periodLabel Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            prefixText: '₹ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (existing != null)
            TextButton(
              onPressed: () {
                ref.read(budgetsControllerProvider.notifier)
                    .deleteBudget(existing.id);
                Navigator.pop(context);
              },
              child: const Text('Remove',
                  style: TextStyle(color: AppColors.error)),
            ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                _saveBudget(ref, period, val, existing);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveBudget(
      WidgetRef ref, String period, double amount, BudgetModel? existing) {
    final now = DateTime.now();
    ref.read(budgetsControllerProvider.notifier).addOrUpdateBudget(
          BudgetModel(
            id: existing?.id ?? const Uuid().v4(),
            amount: amount,
            month: now.month,
            year: now.year,
            categoryId: null,
            period: period,
          ),
        );
  }
}

// ── Category Budget List ───────────────────────────────────────────────────────

class _CategoryBudgetList extends ConsumerWidget {
  final String period;
  const _CategoryBudgetList({required this.period});

  ReportFilter _toReportFilter(String p) {
    final now = DateTime.now();
    switch (p) {
      case 'daily':
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return ReportFilter(startDate: start, endDate: end, viewMode: ReportViewMode.weekly);
      case 'weekly':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return ReportFilter(startDate: start, endDate: end, viewMode: ReportViewMode.weekly);
      default:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(microseconds: 1));
        return ReportFilter(startDate: start, endDate: end, viewMode: ReportViewMode.monthly);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(currentMonthBudgetsProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);
    final reportAsync = ref.watch(reportDataProvider(_toReportFilter(period)));

    return budgetsAsync.when(
      data: (budgets) => categoriesAsync.when(
        data: (categories) => reportAsync.when(
          data: (report) {
            final expenseCategories =
                categories.where((c) => c.type == 'expense').toList();
            return Column(
              children: expenseCategories.map((cat) {
                final b = budgets.cast<dynamic>().firstWhere(
                    (b) => b.categoryId == cat.id && b.period == period,
                    orElse: () => null);
                
                final spent = report.expensesByCategory[cat.id] ?? 0.0;

                return _CategoryBudgetTile(
                  cat: cat,
                  budget: b,
                  spentAmount: spent,
                  period: period,
                  ref: ref,
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const SizedBox.shrink(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const SizedBox.shrink(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _CategoryBudgetTile extends StatelessWidget {
  final CategoryModel cat;
  final BudgetModel? budget;
  final double spentAmount;
  final String period;
  final WidgetRef ref;

  const _CategoryBudgetTile({
    required this.cat,
    required this.budget,
    required this.spentAmount,
    required this.period,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSetCategoryBudgetDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: budget == null
            ? _buildSetLimitRow(context)
            : BudgetProgressBar(
                categoryName: cat.name,
                categoryIcon: cat.icon,
                categoryColor: cat.color,
                budgetAmount: budget!.amount,
                spentAmount: spentAmount,
              ),
      ),
    );
  }

  Widget _buildSetLimitRow(BuildContext context) {
    final catColor = CategoryColorUtils.fromHex(cat.color);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CategoryIconUtils.fromHex(cat.icon),
            color: catColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(cat.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text('Set Limit',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12)),
      ],
    );
  }

  void _showSetCategoryBudgetDialog(BuildContext context) {
    String amount = budget?.amount.toString() ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget: ${cat.name}'),
        content: TextField(
          controller: TextEditingController(text: amount),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            prefixText: '₹ ',
          ),
          onChanged: (val) => amount = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (budget != null)
            TextButton(
              onPressed: () {
                ref.read(budgetsControllerProvider.notifier)
                    .deleteBudget(budget!.id);
                Navigator.pop(context);
              },
              child: const Text('Remove',
                  style: TextStyle(color: AppColors.error)),
            ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(amount);
              if (val != null && val > 0) {
                final now = DateTime.now();
                ref.read(budgetsControllerProvider.notifier).addOrUpdateBudget(
                      BudgetModel(
                        id: budget?.id ?? const Uuid().v4(),
                        amount: val,
                        month: now.month,
                        year: now.year,
                        categoryId: cat.id,
                        period: period,
                      ),
                    );
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
