import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

part 'transaction_providers.g.dart';

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepository();
}

@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  FutureOr<List<TransactionModel>> build() async {
    return _fetchTransactions();
  }

  Future<List<TransactionModel>> _fetchTransactions() async {
    return ref.read(transactionRepositoryProvider).getAllTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).addTransaction(transaction);
      return _fetchTransactions();
    });
  }

  Future<void> addTransactions(List<TransactionModel> transactions) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).addTransactions(transactions);
      return _fetchTransactions();
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).updateTransaction(transaction);
      return _fetchTransactions();
    });
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).deleteTransaction(id);
      return _fetchTransactions();
    });
  }

  Future<void> clearAllTransactions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).clearAllTransactions();
      return _fetchTransactions();
    });
  }
}
