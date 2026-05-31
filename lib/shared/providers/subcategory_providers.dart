import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/hive_database.dart';
import '../../data/models/subcategory_model.dart';

part 'subcategory_providers.g.dart';

@riverpod
class SubcategoriesController extends _$SubcategoriesController {
  @override
  Future<List<SubcategoryModel>> build() async {
    return HiveDatabase.subcategories.values.toList();
  }

  Future<void> addSubcategory(SubcategoryModel sub) async {
    await HiveDatabase.subcategories.put(sub.id, sub);
    ref.invalidateSelf();
  }

  Future<void> deleteSubcategory(String id) async {
    await HiveDatabase.subcategories.delete(id);
    ref.invalidateSelf();
  }

  Future<void> updateSubcategory(SubcategoryModel sub) async {
    await HiveDatabase.subcategories.put(sub.id, sub);
    ref.invalidateSelf();
  }
}

/// Get subcategories for a specific category
final subcategoriesByCategoryProvider =
    Provider.family<List<SubcategoryModel>, String>((ref, categoryId) {
  final allAsync = ref.watch(subcategoriesControllerProvider);
  return allAsync.maybeWhen(
    data: (all) => all.where((s) => s.categoryId == categoryId).toList(),
    orElse: () => [],
  );
});
