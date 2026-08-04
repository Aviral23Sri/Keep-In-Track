import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import 'transaction_providers.dart';
import 'settings_providers.dart';

part 'reports_providers.g.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum ReportViewMode { weekly, monthly, yearly, custom }

// ── Filter ────────────────────────────────────────────────────────────────────

class ReportFilter {
  final DateTime startDate;
  final DateTime endDate;
  final ReportViewMode viewMode;

  const ReportFilter({
    required this.startDate,
    required this.endDate,
    required this.viewMode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFilter &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          viewMode == other.viewMode;

  @override
  int get hashCode => Object.hash(startDate, endDate, viewMode);
}

// ── Data Models ───────────────────────────────────────────────────────────────

class WeekBucket {
  final String label;
  final double income;
  final double expense;

  const WeekBucket({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class ReportData {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;
  final Map<String, double> paymentModeBreakdown;
  final String? highestSpendingCategory;
  final double biggestSingleExpense;
  final double averageDailySpend;
  final List<TransactionModel> topExpenses;
  final List<WeekBucket> weeklyBuckets;

  ReportData({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.paymentModeBreakdown,
    this.highestSpendingCategory,
    required this.biggestSingleExpense,
    required this.averageDailySpend,
    required this.topExpenses,
    required this.weeklyBuckets,
  });
}

class MoMComparison {
  final double currentExpense;
  final double previousExpense;
  final double currentIncome;
  final double previousIncome;

  double get expenseDelta => currentExpense - previousExpense;
  double get incomeDelta => currentIncome - previousIncome;
  double get expenseChangePercent =>
      previousExpense == 0 ? 0 : ((expenseDelta / previousExpense) * 100);
  double get incomeChangePercent =>
      previousIncome == 0 ? 0 : ((incomeDelta / previousIncome) * 100);
  bool get isExpenseBetter => expenseDelta <= 0;
  bool get isIncomeBetter => incomeDelta >= 0;

  const MoMComparison({
    required this.currentExpense,
    required this.previousExpense,
    required this.currentIncome,
    required this.previousIncome,
  });
}

// ── Providers ─────────────────────────────────────────────────────────────────

@riverpod
Future<ReportData> reportData(Ref ref, ReportFilter filter) async {
  final transactions = await ref.watch(transactionsControllerProvider.future);

  final filtered = transactions.where((t) {
    return !t.date.isBefore(filter.startDate) &&
        !t.date.isAfter(filter.endDate);
  }).toList();

  double income = 0, expense = 0, savings = 0, biggestExpense = 0;
  final Map<String, double> byExpCat = {};
  final Map<String, double> byIncCat = {};
  final Map<String, double> byPayMode = {};

  for (final t in filtered) {
    byPayMode[t.paymentMode] = (byPayMode[t.paymentMode] ?? 0) + t.amount;
    if (t.type == 'income') {
      income += t.amount;
      byIncCat[t.categoryId] = (byIncCat[t.categoryId] ?? 0) + t.amount;
    } else if (t.type == 'savings') {
      savings += t.amount;
    } else if (t.type == 'expense') {
      expense += t.amount;
      if (t.amount > biggestExpense) biggestExpense = t.amount;
      byExpCat[t.categoryId] = (byExpCat[t.categoryId] ?? 0) + t.amount;
    }
  }

  String? highestCat;
  double highestAmt = 0;
  byExpCat.forEach((id, amt) {
    if (amt > highestAmt) {
      highestAmt = amt;
      highestCat = id;
    }
  });

  final days = filter.endDate.difference(filter.startDate).inDays + 1;

  final topExpenses = filtered
      .where((t) => t.type == 'expense')
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return ReportData(
    transactions: filtered,
    totalIncome: income,
    totalExpense: expense,
    totalSavings: savings,
    expensesByCategory: byExpCat,
    incomeByCategory: byIncCat,
    paymentModeBreakdown: byPayMode,
    highestSpendingCategory: highestCat,
    biggestSingleExpense: biggestExpense,
    averageDailySpend: days > 0 ? expense / days : 0,
    topExpenses: topExpenses.take(5).toList(),
    weeklyBuckets: _buildBuckets(filtered, filter.startDate, filter.endDate, filter.viewMode),
  );
}

@riverpod
Future<MoMComparison> momComparison(Ref ref, DateTime selectedMonth) async {
  final transactions = await ref.watch(transactionsControllerProvider.future);
  final settings = await ref.watch(settingsControllerProvider.future);
  final sd = settings.monthStartDay;

  final curStart = DateFormatter.startOfMonth(selectedMonth, startDay: sd);
  final curEnd = DateFormatter.endOfMonth(selectedMonth, startDay: sd);
  final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 15);
  final prevStart = DateFormatter.startOfMonth(prevMonth, startDay: sd);
  final prevEnd = DateFormatter.endOfMonth(prevMonth, startDay: sd);

  double curExp = 0, prevExp = 0, curInc = 0, prevInc = 0;
  for (final t in transactions) {
    final inCur = !t.date.isBefore(curStart) && !t.date.isAfter(curEnd);
    final inPrev = !t.date.isBefore(prevStart) && !t.date.isAfter(prevEnd);
    if (inCur) {
      if (t.type == 'expense') curExp += t.amount;
      if (t.type == 'income') curInc += t.amount;
    }
    if (inPrev) {
      if (t.type == 'expense') prevExp += t.amount;
      if (t.type == 'income') prevInc += t.amount;
    }
  }

  return MoMComparison(
    currentExpense: curExp,
    previousExpense: prevExp,
    currentIncome: curInc,
    previousIncome: prevInc,
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

List<WeekBucket> _buildBuckets(List<TransactionModel> txns,
    DateTime start, DateTime end, ReportViewMode mode) {
  if (mode == ReportViewMode.yearly) {
    final Map<int, double> inc = {}, exp = {};
    for (final t in txns) {
      final m = t.date.month;
      if (t.type == 'income') inc[m] = (inc[m] ?? 0) + t.amount;
      if (t.type == 'expense') exp[m] = (exp[m] ?? 0) + t.amount;
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return List.generate(12, (i) => WeekBucket(
      label: months[i], income: inc[i+1] ?? 0, expense: exp[i+1] ?? 0));
  }

  if (mode == ReportViewMode.weekly) {
    final Map<int, double> inc = {}, exp = {};
    for (final t in txns) {
      final d = t.date.weekday;
      if (t.type == 'income') inc[d] = (inc[d] ?? 0) + t.amount;
      if (t.type == 'expense') exp[d] = (exp[d] ?? 0) + t.amount;
    }
    const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return List.generate(7, (i) => WeekBucket(
      label: labels[i], income: inc[i+1] ?? 0, expense: exp[i+1] ?? 0));
  }

  // Monthly / Custom → weekly sub-buckets
  final totalDays = end.difference(start).inDays + 1;
  final numWeeks = (totalDays / 7).ceil().clamp(1, 5);
  final Map<int, double> inc = {}, exp = {};
  for (final t in txns) {
    final offset = t.date.difference(start).inDays;
    final wi = (offset / 7).floor().clamp(0, numWeeks - 1);
    if (t.type == 'income') inc[wi] = (inc[wi] ?? 0) + t.amount;
    if (t.type == 'expense') exp[wi] = (exp[wi] ?? 0) + t.amount;
  }
  return List.generate(numWeeks, (i) => WeekBucket(
    label: 'W${i+1}', income: inc[i] ?? 0, expense: exp[i] ?? 0));
}
