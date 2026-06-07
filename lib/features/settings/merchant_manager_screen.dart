import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/merchant_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/widgets/gradient_app_bar.dart';

class MerchantManagerScreen extends ConsumerWidget {
  const MerchantManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantsAsync = ref.watch(merchantsControllerProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Merchant Memory')),
      body: merchantsAsync.when(
        data: (merchants) {
          if (merchants.isEmpty) {
            return const Center(child: Text('No saved merchants.'));
          }

          // Sort by usage count
          final sortedMerchants = List.of(merchants)
            ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

          return ListView.separated(
            itemCount: sortedMerchants.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final merchant = sortedMerchants[index];
              return categoriesAsync.when(
                data: (categories) {
                  final cat = categories.cast<dynamic>().firstWhere((c) => c.id == merchant.categoryId, orElse: () => null);
                  final catName = cat?.name ?? 'Unknown Category';
                  final amountText = merchant.typicalAmount != null ? ' • ₹${merchant.typicalAmount?.toStringAsFixed(0)}' : '';
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(merchant.name[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                    title: Text(merchant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$catName$amountText'),
                    trailing: Text('Used ${merchant.usageCount}x', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      // Implementation for editing merchant could go here
                    },
                  );
                },
                loading: () => const ListTile(title: Text('Loading...')),
                error: (_, __) => const SizedBox(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
