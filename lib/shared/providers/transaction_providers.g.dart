// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'f2fd41bd98ddadc07031c7a7e946176e8bcbc6c5';

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
    r'02d72f75a3a5a57bb80205e51fa6a8648486a03f';

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
