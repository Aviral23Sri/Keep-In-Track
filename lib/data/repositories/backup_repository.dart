import 'dart:convert';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/merchant_model.dart';
import '../models/subcategory_model.dart';
import '../models/app_settings_model.dart';
import '../datasources/hive_database.dart';

class BackupRepository {
  Future<String> exportBackupToJson() async {
    final transactions = HiveDatabase.transactions.values.map((e) => e.toJson()).toList();
    final categories = HiveDatabase.categories.values.map((e) => e.toJson()).toList();
    final budgets = HiveDatabase.budgets.values.map((e) => e.toJson()).toList();
    final merchants = HiveDatabase.merchants.values.map((e) => e.toJson()).toList();
    // ✅ Export subcategories (both default and user-created)
    final subcategories = HiveDatabase.subcategories.values.map((e) => e.toJson()).toList();
    final settings = HiveDatabase.settings.get('settings')?.toJson();

    final backupData = {
      'version': 2,
      'exportDate': DateTime.now().toIso8601String(),
      'transactions': transactions,
      'categories': categories,
      'budgets': budgets,
      'merchants': merchants,
      'subcategories': subcategories,
      'settings': settings,
    };

    return jsonEncode(backupData);
  }

  Future<void> importBackupFromJson(String jsonString, {bool replaceAll = false}) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    if (replaceAll) {
      await HiveDatabase.clearAll();
    }

    final transactionsList = (data['transactions'] as List?) ?? [];
    for (var json in transactionsList) {
      final tModel = TransactionModel.fromJson(json as Map<String, dynamic>);
      await HiveDatabase.transactions.put(tModel.id, tModel);
    }

    final categoriesList = (data['categories'] as List?) ?? [];
    for (var json in categoriesList) {
      final cModel = CategoryModel.fromJson(json as Map<String, dynamic>);
      await HiveDatabase.categories.put(cModel.id, cModel);
    }

    final budgetsList = (data['budgets'] as List?) ?? [];
    for (var json in budgetsList) {
      final bModel = BudgetModel.fromJson(json as Map<String, dynamic>);
      await HiveDatabase.budgets.put(bModel.id, bModel);
    }

    final merchantsList = (data['merchants'] as List?) ?? [];
    for (var json in merchantsList) {
      final mModel = MerchantModel.fromJson(json as Map<String, dynamic>);
      await HiveDatabase.merchants.put(mModel.id, mModel);
    }

    // ✅ Restore subcategories from backup (if present — v2+ backups)
    final subcategoriesList = (data['subcategories'] as List?) ?? [];
    for (var json in subcategoriesList) {
      final sModel = SubcategoryModel.fromJson(json as Map<String, dynamic>);
      await HiveDatabase.subcategories.put(sModel.id, sModel);
    }

    // ✅ Always re-seed missing default subcategories after import.
    // This guarantees standard subcategories are present even when importing
    // an old v1 backup that didn't include subcategories.
    await HiveDatabase.ensureDefaultSubcategories();

    if (data['settings'] != null) {
      final sModel = AppSettingsModel.fromJson(data['settings'] as Map<String, dynamic>);
      await HiveDatabase.settings.put('settings', sModel);
    }
  }
}
