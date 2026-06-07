// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryRepositoryHash() =>
    r'bf260a6681489d6017fd399b5a76902bdd03e66e';

/// See also [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider = Provider<CategoryRepository>.internal(
  categoryRepository,
  name: r'categoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryRepositoryRef = ProviderRef<CategoryRepository>;
String _$activeCategoriesHash() => r'62f2025b6893eb84d58076b753c9d7d9031a01c2';

/// See also [activeCategories].
@ProviderFor(activeCategories)
final activeCategoriesProvider =
    AutoDisposeFutureProvider<List<CategoryModel>>.internal(
  activeCategories,
  name: r'activeCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCategoriesRef = AutoDisposeFutureProviderRef<List<CategoryModel>>;
String _$categoriesControllerHash() =>
    r'48b8d9719da1f19679586cf9ac6bdfb7b7e77a7d';

/// See also [CategoriesController].
@ProviderFor(CategoriesController)
final categoriesControllerProvider = AutoDisposeAsyncNotifierProvider<
    CategoriesController, List<CategoryModel>>.internal(
  CategoriesController.new,
  name: r'categoriesControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoriesController = AutoDisposeAsyncNotifier<List<CategoryModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
