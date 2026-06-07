import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../shared/providers/reports_providers.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import 'widgets/expense_pie_chart.dart';
import 'widgets/trend_line_chart.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDataProvider(_period));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GradientAppBar(
        title: Text('Reports'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Time Period Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.scaffoldBackgroundColor,
            child: SegmentedButton<ReportPeriod>(
              segments: const [
                ButtonSegment(value: ReportPeriod.daily, label: Text('Daily')),
                ButtonSegment(
                    value: ReportPeriod.weekly, label: Text('Weekly')),
                ButtonSegment(
                    value: ReportPeriod.monthly, label: Text('Monthly')),
                ButtonSegment(
                    value: ReportPeriod.yearly, label: Text('Yearly')),
              ],
              selected: {_period},
              onSelectionChanged: (set) => setState(() => _period = set.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          Expanded(
            child: reportAsync.when(
              data: (report) {
                if (report.transactions.isEmpty) {
                  return const Center(
                      child: Text('No data for selected period.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                            context,
                            'Total Balance',
                            (report.totalIncome - report.totalExpense),
                            AppColors.primary),
                        _buildStatCard(context, 'Avg Daily Spend',
                            report.averageDailySpend, AppColors.warning),
                        _buildStatCard(context, 'Total Income',
                            report.totalIncome, AppColors.income),
                        _buildStatCard(context, 'Total Expense',
                            report.totalExpense, AppColors.expense),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text('Expense Breakdown',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ExpensePieChart(
                        expensesByCategory: report.expensesByCategory,
                        totalExpense: report.totalExpense),

                    const SizedBox(height: 32),

                    const Text('Spending Trend',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TrendLineChart(
                        transactions: report.transactions, period: _period),

                    const SizedBox(height: 40),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
