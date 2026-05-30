import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import 'transaction_providers.dart';
import 'settings_providers.dart';

part 'reports_providers.g.dart';

enum ReportPeriod { daily, weekly, monthly, yearly }

class ReportData {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final Map<String, double> expensesByCategory;
  final String? highestSpendingCategory;
  final double biggestSingleExpense;
  final double averageDailySpend;

  ReportData({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.expensesByCategory,
    this.highestSpendingCategory,
    required this.biggestSingleExpense,
    required this.averageDailySpend,
  });
}

@riverpod
Future<ReportData> reportData(ReportDataRef ref, ReportPeriod period) async {
  final transactions = await ref.watch(transactionsControllerProvider.future);
  final settings = await ref.watch(settingsControllerProvider.future);
  
  final now = DateTime.now();
  DateTime startDate;
  DateTime endDate = now;

  switch (period) {
    case ReportPeriod.daily:
      startDate = DateTime(now.year, now.month, now.day);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case ReportPeriod.weekly:
      // Last 7 days including today
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case ReportPeriod.monthly:
      startDate = DateFormatter.startOfMonth(now, startDay: settings.monthStartDay);
      endDate = DateFormatter.endOfMonth(now, startDay: settings.monthStartDay);
      break;
    case ReportPeriod.yearly:
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year, 12, 31, 23, 59, 59);
      break;
  }

  final filtered = transactions.where((t) {
    return t.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
           t.date.isBefore(endDate.add(const Duration(seconds: 1)));
  }).toList();

  double income = 0;
  double expense = 0;
  double savings = 0;
  double biggestExpense = 0;
  Map<String, double> byCategory = {};

  for (final t in filtered) {
    if (t.type == 'income') {
      income += t.amount;
    } else if (t.type == 'savings') {
      savings += t.amount;
    } else if (t.type == 'expense') {
      expense += t.amount;
      if (t.amount > biggestExpense) biggestExpense = t.amount;
      byCategory[t.categoryId] = (byCategory[t.categoryId] ?? 0) + t.amount;
    }
  }

  String? highestCategory;
  double highestCategoryAmount = 0;
  byCategory.forEach((catId, amount) {
    if (amount > highestCategoryAmount) {
      highestCategoryAmount = amount;
      highestCategory = catId;
    }
  });

  int days = endDate.difference(startDate).inDays + 1;
  double avgDaily = expense / days;

  return ReportData(
    transactions: filtered,
    totalIncome: income,
    totalExpense: expense,
    totalSavings: savings,
    expensesByCategory: byCategory,
    highestSpendingCategory: highestCategory,
    biggestSingleExpense: biggestExpense,
    averageDailySpend: avgDaily,
  );
}
