import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import 'transaction_providers.dart';

part 'budget_providers.g.dart';

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  return BudgetRepository();
}

@riverpod
class BudgetsController extends _$BudgetsController {
  @override
  FutureOr<List<BudgetModel>> build() async {
    return _fetchBudgets();
  }

  Future<List<BudgetModel>> _fetchBudgets() async {
    return ref.read(budgetRepositoryProvider).getAllBudgets();
  }

  Future<void> addOrUpdateBudget(BudgetModel budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetRepositoryProvider).addOrUpdateBudget(budget);
      return _fetchBudgets();
    });
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetRepositoryProvider).deleteBudget(id);
      return _fetchBudgets();
    });
  }
}

@riverpod
Future<List<BudgetModel>> currentMonthBudgets(Ref ref) async {
  final budgets = await ref.watch(budgetsControllerProvider.future);
  final now = DateTime.now();
  return budgets.where((b) => b.month == now.month && b.year == now.year).toList();
}

// ── Period spend providers ─────────────────────────────────────────────────────

/// Total expense spend for TODAY
final dailySpendProvider = FutureProvider<double>((ref) async {
  final txns = await ref.watch(transactionsControllerProvider.future);
  final today = DateTime.now();
  return txns
      .where((t) =>
          t.type == 'expense' &&
          t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

/// Total expense spend for THIS WEEK (Mon–Sun)
final weeklySpendProvider = FutureProvider<double>((ref) async {
  final txns = await ref.watch(transactionsControllerProvider.future);
  final now = DateTime.now();
  // Monday of current week
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(monday.year, monday.month, monday.day);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return txns
      .where((t) =>
          t.type == 'expense' &&
          !t.date.isBefore(weekStart) &&
          t.date.isBefore(weekEnd))
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

/// Total expense spend for THIS MONTH
final monthlySpendProvider = FutureProvider<double>((ref) async {
  final txns = await ref.watch(transactionsControllerProvider.future);
  final now = DateTime.now();
  return txns
      .where((t) =>
          t.type == 'expense' &&
          t.date.year == now.year &&
          t.date.month == now.month)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

/// Selected budget period tab: 'daily' | 'weekly' | 'monthly'
final budgetPeriodProvider = StateProvider<String>((ref) => 'monthly');
