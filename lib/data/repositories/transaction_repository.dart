import '../models/transaction_model.dart';
import '../datasources/hive_database.dart';

class TransactionRepository {
  Future<List<TransactionModel>> getAllTransactions() async {
    return HiveDatabase.transactions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await HiveDatabase.transactions.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await HiveDatabase.transactions.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await HiveDatabase.transactions.delete(id);
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    return HiveDatabase.transactions.get(id);
  }
}
