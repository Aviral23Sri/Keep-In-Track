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

  Future<void> addTransactions(List<TransactionModel> transactions) async {
    final Map<String, TransactionModel> map = {};
    for (var t in transactions) {
      map[t.id] = t;
    }
    await HiveDatabase.transactions.putAll(map);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await HiveDatabase.transactions.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await HiveDatabase.transactions.delete(id);
  }

  Future<void> deleteTransactions(List<String> ids) async {
    await HiveDatabase.transactions.deleteAll(ids);
  }

  Future<void> clearAllTransactions() async {
    await HiveDatabase.transactions.clear();
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    return HiveDatabase.transactions.get(id);
  }
}
