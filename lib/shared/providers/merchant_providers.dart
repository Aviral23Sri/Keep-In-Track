import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/merchant_model.dart';
import '../../data/repositories/merchant_repository.dart';

part 'merchant_providers.g.dart';

@Riverpod(keepAlive: true)
MerchantRepository merchantRepository(Ref ref) {
  return MerchantRepository();
}

@riverpod
class MerchantsController extends _$MerchantsController {
  @override
  FutureOr<List<MerchantModel>> build() async {
    return _fetchMerchants();
  }

  Future<List<MerchantModel>> _fetchMerchants() async {
    return ref.read(merchantRepositoryProvider).getAllMerchants();
  }

  Future<void> addMerchant(MerchantModel merchant) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(merchantRepositoryProvider).addMerchant(merchant);
      return _fetchMerchants();
    });
  }

  Future<void> updateMerchant(MerchantModel merchant) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(merchantRepositoryProvider).updateMerchant(merchant);
      return _fetchMerchants();
    });
  }

  Future<void> deleteMerchant(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(merchantRepositoryProvider).deleteMerchant(id);
      return _fetchMerchants();
    });
  }

  Future<void> incrementUsage(String id) async {
    // Optimistic update in state is not strictly required since it's just usage count,
    // but doing it for completeness.
    await ref.read(merchantRepositoryProvider).incrementUsage(id);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<MerchantModel>> searchMerchants(Ref ref, String query) async {
  if (query.trim().isEmpty) return [];
  return ref.read(merchantRepositoryProvider).searchMerchants(query);
}
