import '../models/budget_model.dart';
import '../datasources/hive_database.dart';

class BudgetRepository {
  Future<List<BudgetModel>> getAllBudgets() async {
    return HiveDatabase.budgets.values.toList();
  }

  Future<List<BudgetModel>> getBudgetsForMonth(int month, int year) async {
    return HiveDatabase.budgets.values
        .where((b) => b.month == month && b.year == year)
        .toList();
  }

  Future<void> addOrUpdateBudget(BudgetModel budget) async {
    // If a budget for this category/overall already exists for the month/year, overwrite it.
    final existing = HiveDatabase.budgets.values.cast<BudgetModel?>().firstWhere(
      (b) => b?.categoryId == budget.categoryId && b?.month == budget.month && b?.year == budget.year,
      orElse: () => null,
    );

    if (existing != null) {
      await HiveDatabase.budgets.put(existing.id, budget.copyWith(id: existing.id));
    } else {
      await HiveDatabase.budgets.put(budget.id, budget);
    }
  }

  Future<void> deleteBudget(String id) async {
    await HiveDatabase.budgets.delete(id);
  }
}
