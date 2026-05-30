import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../data/models/category_model.dart';
import 'package:collection/collection.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../dashboard/widgets/transaction_tile.dart';

class CategoryTransactionsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryTransactionsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsControllerProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    // Build the UI based on the categories async value so we can access the selected category
    return categoriesAsync.when(
      data: (categories) {
        final CategoryModel? cat =
            categories.firstWhereOrNull((c) => c.id == categoryId);
        return Scaffold(
          appBar: GradientAppBar(
            title: Text(cat != null
                ? '${cat.name} Transactions'
                : 'Category Transactions'),
            actions: [
              if (cat != null && !cat.isDefault)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDeleteCategory(context, ref, cat),
                ),
            ],
          ),
          body: transactionsAsync.when(
            data: (transactions) {
              final filtered = transactions
                  .where((t) => t.categoryId == categoryId)
                  .toList();

              if (filtered.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Transactions',
                  message: 'You have no transactions for this category.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  return TransactionTile(
                    transaction: t,
                    onTap: () => context.push('/add-transaction?id=${t.id}'),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryModel cat,
  ) async {
    final txCount = await ref
        .read(categoriesControllerProvider.notifier)
        .linkedTransactionCount(cat.id);

    final content = txCount > 0
        ? 'Delete "${cat.name}"? This will also remove $txCount linked transaction${txCount == 1 ? '' : 's'}.'
        : 'Delete "${cat.name}"? This cannot be undone.';

    final confirm = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Category',
      content: content,
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirm || !context.mounted) return;

    final deleted = await ref
        .read(categoriesControllerProvider.notifier)
        .deleteCategory(cat.id);

    if (!context.mounted) return;

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${cat.name}" deleted')),
      );
      // After deletion, navigate back to categories list
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete this category')),
      );
    }
  }
}
