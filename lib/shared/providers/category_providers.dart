import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import 'transaction_providers.dart';
import 'budget_providers.dart';

part 'category_providers.g.dart';

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository();
}

@riverpod
class CategoriesController extends _$CategoriesController {
  @override
  FutureOr<List<CategoryModel>> build() async {
    return _fetchCategories();
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    return ref.read(categoryRepositoryProvider).getAllCategories();
  }

  Future<void> addCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).addCategory(category);
      return _fetchCategories();
    });
  }

  Future<void> updateCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).updateCategory(category);
      return _fetchCategories();
    });
  }

  Future<bool> deleteCategory(String id) async {
    final repo = ref.read(categoryRepositoryProvider);
    final cat = await repo.getCategoryById(id);
    if (cat == null || cat.isDefault) return false;

    state = const AsyncValue.loading();
    try {
      final deleted = await repo.deleteCategory(id);
      if (deleted) {
        ref.invalidate(transactionsControllerProvider);
        ref.invalidate(budgetsControllerProvider);
      }
      state = AsyncValue.data(await _fetchCategories());
      return deleted;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<int> linkedTransactionCount(String categoryId) async {
    return ref
        .read(categoryRepositoryProvider)
        .countLinkedTransactions(categoryId);
  }
}

@riverpod
Future<List<CategoryModel>> activeCategories(ActiveCategoriesRef ref) async {
  final controller = ref.watch(categoriesControllerProvider.future);
  final all = await controller;
  return all.where((c) => !c.isHidden).toList();
}
