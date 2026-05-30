import '../models/merchant_model.dart';
import '../datasources/hive_database.dart';

class MerchantRepository {
  Future<List<MerchantModel>> getAllMerchants() async {
    return HiveDatabase.merchants.values.toList();
  }

  Future<List<MerchantModel>> searchMerchants(String query) async {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    
    final all = HiveDatabase.merchants.values.toList();
    
    // Simple fuzzy/partial matching
    final matches = all.where((m) {
      if (m.name.toLowerCase().contains(lowerQuery)) return true;
      for (final variant in m.nameVariants) {
        if (variant.toLowerCase().contains(lowerQuery)) return true;
      }
      return false;
    }).toList();

    // Sort by usage count (most used first)
    matches.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return matches;
  }

  Future<void> addMerchant(MerchantModel merchant) async {
    await HiveDatabase.merchants.put(merchant.id, merchant);
  }

  Future<void> updateMerchant(MerchantModel merchant) async {
    await HiveDatabase.merchants.put(merchant.id, merchant);
  }

  Future<void> deleteMerchant(String id) async {
    await HiveDatabase.merchants.delete(id);
  }

  Future<void> incrementUsage(String id) async {
    final merchant = HiveDatabase.merchants.get(id);
    if (merchant != null) {
      await HiveDatabase.merchants.put(id, merchant.copyWith(
        usageCount: merchant.usageCount + 1,
        lastUsed: DateTime.now(),
      ));
    }
  }
}
