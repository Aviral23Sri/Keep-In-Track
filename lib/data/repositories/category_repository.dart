import '../models/category_model.dart';
import '../datasources/hive_database.dart';

class CategoryRepository {
  Future<List<CategoryModel>> getAllCategories() async {
    return HiveDatabase.categories.values.toList();
  }

  Future<List<CategoryModel>> getActiveCategories() async {
    return HiveDatabase.categories.values.where((c) => !c.isHidden).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await HiveDatabase.categories.put(category.id, category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await HiveDatabase.categories.put(category.id, category);
  }

  Future<int> countLinkedTransactions(String categoryId) async {
    return HiveDatabase.transactions.values
        .where((t) => t.categoryId == categoryId)
        .length;
  }

  Future<bool> deleteCategory(String id) async {
    final cat = HiveDatabase.categories.get(id);
    if (cat == null || cat.isDefault) return false;

    final transactionIds = HiveDatabase.transactions.values
        .where((t) => t.categoryId == id)
        .map((t) => t.id)
        .toList();
    for (final txId in transactionIds) {
      await HiveDatabase.transactions.delete(txId);
    }

    final budgetIds = HiveDatabase.budgets.values
        .where((b) => b.categoryId == id)
        .map((b) => b.id)
        .toList();
    for (final budgetId in budgetIds) {
      await HiveDatabase.budgets.delete(budgetId);
    }

    await HiveDatabase.categories.delete(id);
    return true;
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    return HiveDatabase.categories.get(id);
  }
}
