import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/category_color_utils.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/subcategory_providers.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import 'parsed_transaction.dart';

class ImportReviewScreen extends ConsumerStatefulWidget {
  final List<ParsedTransaction> transactions;

  const ImportReviewScreen({super.key, required this.transactions});

  @override
  ConsumerState<ImportReviewScreen> createState() =>
      _ImportReviewScreenState();
}

class _ImportReviewScreenState extends ConsumerState<ImportReviewScreen> {
  late List<ParsedTransaction> _transactions;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions);
  }

  int get _selectedCount =>
      _transactions.where((t) => t.isSelected).length;

  Future<void> _importSelected() async {
    setState(() => _isImporting = true);
    final notifier = ref.read(transactionsControllerProvider.notifier);

    try {
      // Deduplicate: check existing bankRefNumbers
      final existing =
          await ref.read(transactionsControllerProvider.future);
      final existingRefs = existing
          .map((t) => t.bankRefNumber)
          .whereType<String>()
          .toSet();

      final existingSignatures = existing
          .where((t) => t.bankRefNumber == null)
          .map((t) => '${t.date.millisecondsSinceEpoch}_${t.amount}_${t.title}')
          .toSet();

      int importCount = 0;
      final List<TransactionModel> newTransactions = [];

      for (final parsed in _transactions) {
        if (!parsed.isSelected) continue;
        if (parsed.bankRefNumber != null) {
          if (existingRefs.contains(parsed.bankRefNumber)) continue;
        } else {
          final sig = '${parsed.date.millisecondsSinceEpoch}_${parsed.amount}_${parsed.merchantName}';
          if (existingSignatures.contains(sig)) continue;
        }

        final t = TransactionModel(
          id: const Uuid().v4(),
          type: parsed.type,
          amount: parsed.amount,
          categoryId: parsed.categoryId,
          subcategoryId: parsed.subcategoryId,
          title: parsed.merchantName,
          note: parsed.note,
          date: parsed.date,
          paymentMode: 'UPI',
          isRecurring: false,
          createdAt: DateTime.now(),
          bankRefNumber: parsed.bankRefNumber,
          importedFromBank: true,
        );

        newTransactions.add(t);
        importCount++;
      }
      
      if (newTransactions.isNotEmpty) {
        await notifier.addTransactions(newTransactions);
      }

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Imported $importCount transactions'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error importing: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(activeCategoriesProvider);
    final subcategoriesAsync = ref.watch(subcategoriesControllerProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Review Transactions'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (final t in _transactions) {
                t.isSelected = true;
              }
            }),
            child: const Text('All', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => setState(() {
              for (final t in _transactions) {
                t.isSelected = false;
              }
            }),
            child: const Text('None', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return Column(
            children: [
              // Summary bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                color: theme.cardColor,
                child: Row(
                  children: [
                    Text(
                      '${_transactions.length} found  •  $_selectedCount selected',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (_transactions.any((t) => t.needsReview))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_transactions.where((t) => t.needsReview).length} need review',
                          style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Transaction list
              Expanded(
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    final cat = categories.cast<dynamic>().firstWhere(
                          (c) => c.id == tx.categoryId,
                          orElse: () => null,
                        );
                    final catColor = cat != null
                        ? CategoryColorUtils.fromHex(cat.color)
                        : AppColors.primary;

                    return InkWell(
                      onTap: () {
                        subcategoriesAsync.whenData((subs) {
                          _showEditDialog(context, tx, index, categories, subs);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.dividerColor),
                          ),
                          color: tx.needsReview
                              ? AppColors.warning.withValues(alpha: 0.04)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            Checkbox(
                              value: tx.isSelected,
                              onChanged: (v) => setState(() {
                                _transactions[index].isSelected = v ?? false;
                              }),
                              activeColor: AppColors.primary,
                            ),
                            // Category icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat != null
                                    ? CategoryIconUtils.fromHex(cat.icon)
                                    : Icons.category,
                                color: catColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tx.merchantName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (tx.needsReview)
                                        const Icon(Icons.warning_amber,
                                            size: 14,
                                            color: AppColors.warning),
                                    ],
                                  ),
                                    Text(
                                      '${DateFormatter.formatShort(tx.date)}  •  ${cat?.name ?? tx.categoryId}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textTheme.bodySmall
                                              ?.color),
                                    ),
                                    if (tx.subcategoryId != null)
                                      Text(
                                        subcategoriesAsync.maybeWhen(
                                          data: (subs) {
                                            final s = subs.cast<dynamic>().firstWhere(
                                              (sub) => sub.id == tx.subcategoryId,
                                              orElse: () => null,
                                            );
                                            return s?.name ?? '';
                                          },
                                          orElse: () => '',
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            // Amount
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 90),
                              child: Text(
                                '${tx.isDebit ? '−' : '+'}${CurrencyFormatter.format(tx.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tx.isDebit
                                      ? AppColors.expense
                                      : AppColors.income,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _selectedCount == 0 || _isImporting
                ? null
                : _importSelected,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isImporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Import $_selectedCount Transactions'),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ParsedTransaction tx, int index,
      List categories, List subcategories) {
    String selectedCategoryId = tx.categoryId;
    String? selectedSubcategoryId = tx.subcategoryId;
    String note = tx.note ?? '';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final applicableCategories = categories.where((c) => c.type == tx.type).toList();
        
        // Safeguard: If the currently selected category is not in the list for this transaction type
        // (e.g. a DR transaction incorrectly mapped to an Income category like Rakesh CR), fallback.
        if (!applicableCategories.any((c) => c.id == selectedCategoryId)) {
          selectedCategoryId = applicableCategories.isNotEmpty ? applicableCategories.first.id as String : '';
          selectedSubcategoryId = null;
        }

        final applicableSubs = subcategories.where((s) => s.categoryId == selectedCategoryId).toList();
        // If selectedSubcategoryId doesn't belong to the newly selected category, reset it
        if (selectedSubcategoryId != null && !applicableSubs.any((s) => s.id == selectedSubcategoryId)) {
          selectedSubcategoryId = null;
        }

        return AlertDialog(
          title: Text(tx.merchantName, overflow: TextOverflow.ellipsis),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: ${CurrencyFormatter.format(tx.amount)}'),
              Text('Date: ${DateFormatter.formatShort(tx.date)}'),
              const SizedBox(height: 16),
              const Text('Category:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCategoryId,
                items: applicableCategories
                    .map<DropdownMenuItem<String>>(
                      (c) => DropdownMenuItem(
                        value: c.id as String,
                        child: Text(c.name as String,
                            overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setS(() {
                      selectedCategoryId = val;
                      selectedSubcategoryId = null; // reset subcat on cat change
                    });
                  }
                },
              ),
              if (applicableSubs.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Subcategory:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<String?>(
                  isExpanded: true,
                  value: selectedSubcategoryId,
                  hint: const Text('None'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...applicableSubs.map<DropdownMenuItem<String?>>(
                      (s) => DropdownMenuItem(
                        value: s.id as String,
                        child: Text(s.name as String,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setS(() => selectedSubcategoryId = val);
                  },
                ),
              ],
              const SizedBox(height: 16),
              const Text('Note:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: note)..selection = TextSelection.collapsed(offset: note?.length ?? 0),
                decoration: const InputDecoration(
                  hintText: 'Add a note',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => note = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  final newNote = (note == null || note!.trim().isEmpty) ? null : note!.trim();
                  final updatedTx = tx.copyWith(
                    categoryId: selectedCategoryId, 
                    type: tx.type,
                    needsReview: false,
                  );
                  
                  updatedTx.subcategoryId = selectedSubcategoryId;
                  updatedTx.note = newNote;
                  
                  _transactions[index] = updatedTx;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }
}
