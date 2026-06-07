import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/date_formatter.dart';
import 'transaction_providers.dart';
import 'settings_providers.dart';

part 'dashboard_providers.g.dart';

class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double balance;

  DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.balance,
  });
}

@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) async {
  final transactions = await ref.watch(transactionsControllerProvider.future);
  final settings = await ref.watch(settingsControllerProvider.future);

  final now = DateTime.now();
  final startOfMonth =
      DateFormatter.startOfMonth(now, startDay: settings.monthStartDay);
  final endOfMonth =
      DateFormatter.endOfMonth(now, startDay: settings.monthStartDay);

  double income = 0;
  double expense = 0;
  double savings = 0;

  for (final t in transactions) {
    if (t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
        t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)))) {
      if (t.type == 'income') {
        income += t.amount;
      } else if (t.type == 'expense')
        expense += t.amount;
      else if (t.type == 'savings') savings += t.amount;
    }
  }

  return DashboardSummary(
    totalIncome: income,
    totalExpense: expense,
    totalSavings: savings,
    balance: income - expense, // Following the prompt: Income - Expense
  );
}
