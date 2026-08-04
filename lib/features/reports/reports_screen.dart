import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/providers/reports_providers.dart';
import '../../shared/providers/settings_providers.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import 'widgets/month_navigator.dart';
import 'widgets/summary_chips_row.dart';
import 'widgets/income_expense_bar_chart.dart';
import 'widgets/category_donut_breakdown.dart';
import 'widgets/top_transactions_card.dart';
import 'widgets/payment_mode_chart.dart';
import 'widgets/mom_comparison_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  ReportViewMode _viewMode = ReportViewMode.monthly;
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Date Range Logic ────────────────────────────────────────────────────────

  (DateTime, DateTime) _getDateRange() {
    final settingsValue = ref.read(settingsControllerProvider).value;
    final startDay = settingsValue?.monthStartDay ?? 1;

    switch (_viewMode) {
      case ReportViewMode.weekly:
        final weekday = _selectedDate.weekday;
        final monday = _selectedDate.subtract(Duration(days: weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return (start, end);

      case ReportViewMode.monthly:
        final start = DateFormatter.startOfMonth(_selectedDate, startDay: startDay);
        final end = DateFormatter.endOfMonth(_selectedDate, startDay: startDay);
        return (start, end);

      case ReportViewMode.yearly:
        final start = DateTime(_selectedDate.year, 1, 1);
        final end = DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
        return (start, end);

      case ReportViewMode.custom:
        final start = DateFormatter.startOfMonth(_selectedDate, startDay: startDay);
        final end = DateFormatter.endOfMonth(_selectedDate, startDay: startDay);
        return (start, end);
    }
  }

  void _goToPrev() {
    setState(() {
      switch (_viewMode) {
        case ReportViewMode.weekly:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case ReportViewMode.monthly:
        case ReportViewMode.custom:
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
        case ReportViewMode.yearly:
          _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
          break;
      }
    });
  }

  void _goToNext() {
    setState(() {
      switch (_viewMode) {
        case ReportViewMode.weekly:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case ReportViewMode.monthly:
        case ReportViewMode.custom:
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
          break;
        case ReportViewMode.yearly:
          _selectedDate = DateTime(_selectedDate.year + 1, 1, 1);
          break;
      }
    });
  }

  bool _canGoNext() {
    final now = DateTime.now();
    switch (_viewMode) {
      case ReportViewMode.weekly:
        // Can go next if selected week's Monday is before this week's Monday
        final thisWeekMonday = now.subtract(Duration(days: now.weekday - 1));
        final selWeekMonday = _selectedDate
            .subtract(Duration(days: _selectedDate.weekday - 1));
        return selWeekMonday.isBefore(DateTime(
            thisWeekMonday.year, thisWeekMonday.month, thisWeekMonday.day));
      case ReportViewMode.monthly:
      case ReportViewMode.custom:
        return _selectedDate.year < now.year ||
            (_selectedDate.year == now.year &&
                _selectedDate.month < now.month);
      case ReportViewMode.yearly:
        return _selectedDate.year < now.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (startDate, endDate) = _getDateRange();
    final filter = ReportFilter(
      startDate: startDate,
      endDate: endDate,
      viewMode: _viewMode,
    );

    final reportAsync = ref.watch(reportDataProvider(filter));
    final momAsync = _viewMode == ReportViewMode.monthly
        ? ref.watch(momComparisonProvider(_selectedDate))
        : null;

    return Scaffold(
      appBar: const GradientAppBar(
        title: Text('Reports'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Navigator ────────────────────────────────────────────────────
          MonthNavigator(
            viewMode: _viewMode,
            selectedMonth: _selectedDate,
            onViewModeChanged: (mode) {
              setState(() {
                _viewMode = mode;
                _selectedDate = DateTime.now();
              });
            },
            onPrev: _goToPrev,
            onNext: _goToNext,
            canGoNext: _canGoNext(),
          ),

          // ── Tabs ────────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor:
                Theme.of(context).textTheme.bodySmall?.color,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Categories'),
              Tab(text: 'Insights'),
            ],
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: reportAsync.when(
              data: (report) => TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 1: Overview ──────────────────────────────────────
                  _buildOverviewTab(report, momAsync),

                  // ── Tab 2: Categories ────────────────────────────────────
                  _buildCategoriesTab(report),

                  // ── Tab 3: Insights ──────────────────────────────────────
                  _buildInsightsTab(report),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Builders ─────────────────────────────────────────────────────────────

  Widget _buildOverviewTab(ReportData report, AsyncValue<MoMComparison>? momAsync) {
    if (report.transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Summary chips
        const SizedBox(height: 4),
        SummaryChipsRow(
          totalIncome: report.totalIncome,
          totalExpense: report.totalExpense,
          totalSavings: report.totalSavings,
          avgDailySpend: report.averageDailySpend,
        ),
        const SizedBox(height: 16),

        // Bar chart
        IncomeExpenseBarChart(buckets: report.weeklyBuckets),
        const SizedBox(height: 16),

        // MoM comparison (monthly view only)
        if (momAsync != null)
          momAsync.when(
            data: (mom) => MomComparisonCard(
              mom: mom,
              currentMonth: _selectedDate,
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        if (momAsync != null) const SizedBox(height: 16),

        // Top transactions
        TopTransactionsCard(topExpenses: report.topExpenses),
      ],
    );
  }

  Widget _buildCategoriesTab(ReportData report) {
    if (report.transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        CategoryDonutBreakdown(
          expensesByCategory: report.expensesByCategory,
          incomeByCategory: report.incomeByCategory,
          totalExpense: report.totalExpense,
          totalIncome: report.totalIncome,
        ),
      ],
    );
  }

  Widget _buildInsightsTab(ReportData report) {
    if (report.transactions.isEmpty) {
      return _buildEmptyState();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Payment mode
        PaymentModeChart(
          breakdown: report.paymentModeBreakdown,
          totalExpense: report.totalExpense + report.totalIncome + report.totalSavings,
        ),
        const SizedBox(height: 16),

        // Quick stats card
        Container(
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
                  const Icon(Icons.insights_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Quick Stats',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              _StatRow(
                label: 'Total Transactions',
                value: report.transactions.length.toString(),
                icon: Icons.receipt_long_rounded,
                color: AppColors.primary,
              ),
              _StatRow(
                label: 'Largest Expense',
                value: '₹${NumberFormat('#,##,###').format(report.biggestSingleExpense)}',
                icon: Icons.arrow_upward_rounded,
                color: AppColors.expense,
              ),
              _StatRow(
                label: 'Avg Daily Spend',
                value: '₹${NumberFormat('#,##,###').format(report.averageDailySpend)}',
                icon: Icons.today_rounded,
                color: AppColors.warning,
              ),
              _StatRow(
                label: 'Savings Rate',
                value: report.totalIncome > 0
                    ? '${((1 - report.totalExpense / report.totalIncome) * 100).clamp(0, 100).toStringAsFixed(1)}%'
                    : 'N/A',
                icon: Icons.savings_rounded,
                color: AppColors.savings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 72,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No data for this period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try navigating to a different period',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
