// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetRepositoryHash() => r'5078c029d94bcfb1f72180affab685a8cba38d48';

/// See also [budgetRepository].
@ProviderFor(budgetRepository)
final budgetRepositoryProvider = Provider<BudgetRepository>.internal(
  budgetRepository,
  name: r'budgetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetRepositoryRef = ProviderRef<BudgetRepository>;
String _$currentMonthBudgetsHash() =>
    r'7585d7585653c866a80893bf04abef55ed4c318c';

/// See also [currentMonthBudgets].
@ProviderFor(currentMonthBudgets)
final currentMonthBudgetsProvider =
    AutoDisposeFutureProvider<List<BudgetModel>>.internal(
  currentMonthBudgets,
  name: r'currentMonthBudgetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMonthBudgetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMonthBudgetsRef
    = AutoDisposeFutureProviderRef<List<BudgetModel>>;
String _$budgetsControllerHash() => r'37e2c3f7796d20f14f2e6d4803fdd312c39c1386';

/// See also [BudgetsController].
@ProviderFor(BudgetsController)
final budgetsControllerProvider = AutoDisposeAsyncNotifierProvider<
    BudgetsController, List<BudgetModel>>.internal(
  BudgetsController.new,
  name: r'budgetsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BudgetsController = AutoDisposeAsyncNotifier<List<BudgetModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
