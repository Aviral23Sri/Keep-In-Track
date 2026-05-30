import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';

part 'budget_providers.g.dart';

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(BudgetRepositoryRef ref) {
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
Future<List<BudgetModel>> currentMonthBudgets(CurrentMonthBudgetsRef ref) async {
  final budgets = await ref.watch(budgetsControllerProvider.future);
  final now = DateTime.now();
  return budgets.where((b) => b.month == now.month && b.year == now.year).toList();
}
