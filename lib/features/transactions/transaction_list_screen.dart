import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
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
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transactions?'),
        content: Text('Are you sure you want to delete ${_selectedIds.length} selected transactions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(transactionsControllerProvider.notifier).deleteTransactions(_selectedIds.toList());
      _clearSelection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transactions deleted successfully')),
        );
      }
    }
  }

  List<TransactionModel> _getFiltered(List<TransactionModel> transactions) {
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
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsControllerProvider);
    final isSelectionMode = _selectedIds.isNotEmpty;
    
    final List<TransactionModel> allTransactions = transactionsAsync.valueOrNull ?? [];
    final filtered = _getFiltered(allTransactions);

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(isSelectionMode ? '${_selectedIds.length} Selected' : 'Transactions'),
        leading: isSelectionMode 
            ? IconButton(icon: const Icon(Icons.close), onPressed: _clearSelection) 
            : null,
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: Icon(
                _selectedIds.length == filtered.length 
                    ? Icons.deselect 
                    : Icons.select_all
              ),
              onPressed: () {
                setState(() {
                  if (_selectedIds.length == filtered.length) {
                    _selectedIds.clear();
                  } else {
                    _selectedIds.addAll(filtered.map((t) => t.id));
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelected,
            )
          ]
        ],
      ),
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
                // 'filtered' is already computed in build()

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
                      isSelected: _selectedIds.contains(t.id),
                      onLongPress: () {
                        if (!isSelectionMode) {
                          _toggleSelection(t.id);
                        }
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleSelection(t.id);
                        } else {
                          context.push('/add-transaction?id=${t.id}');
                        }
                      },
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
