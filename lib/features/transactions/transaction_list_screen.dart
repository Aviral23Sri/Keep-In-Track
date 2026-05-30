import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../dashboard/widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsControllerProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filterType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'savings', child: Text('Savings')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _filterType = val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                var filtered = transactions;
                if (_filterType != 'all') {
                  filtered = filtered.where((t) => t.type == _filterType).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((t) => 
                    (t.title?.toLowerCase().contains(_searchQuery) ?? false) ||
                    t.amount.toString().contains(_searchQuery)
                  ).toList();
                }

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Transactions',
                    message: 'You have no transactions matching your criteria.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
