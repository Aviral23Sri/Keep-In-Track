// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'288d0c4b0b47a2abf64a8bb8ab5c552540a9a9f5';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider = Provider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef = ProviderRef<TransactionRepository>;
String _$transactionsControllerHash() =>
    r'9f6c31acb13c96990d8e125d8f8986233a307929';

/// See also [TransactionsController].
@ProviderFor(TransactionsController)
final transactionsControllerProvider = AutoDisposeAsyncNotifierProvider<
    TransactionsController, List<TransactionModel>>.internal(
  TransactionsController.new,
  name: r'transactionsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionsController
    = AutoDisposeAsyncNotifier<List<TransactionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
