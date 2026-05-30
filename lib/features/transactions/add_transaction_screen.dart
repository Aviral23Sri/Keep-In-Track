import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/merchant_model.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/merchant_providers.dart';
import '../../core/utils/category_color_utils.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import 'widgets/merchant_autocomplete.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  const AddTransactionScreen({super.key, this.transactionId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'expense';
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  String _paymentMode = 'UPI';

  bool _isRecurring = false;
  String? _recurringFrequency;

  MerchantModel? _selectedMerchant;
  bool _isEditing = false;
  TransactionModel? _editingTransaction;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _isEditing = true;
      _loadTransactionData();
    }
  }

  Future<void> _loadTransactionData() async {
    // This would typically read from a specific provider, but for simplicity we fetch all and find it
    final list = await ref.read(transactionsControllerProvider.future);
    try {
      final t = list.firstWhere((e) => e.id == widget.transactionId);
      setState(() {
        _editingTransaction = t;
        _type = t.type;
        _amountController.text = t.amount.toString();
        _titleController.text = t.title ?? '';
        _noteController.text = t.note ?? '';
        _selectedCategoryId = t.categoryId;
        _date = t.date;
        _paymentMode = t.paymentMode;
        _isRecurring = t.isRecurring;
        _recurringFrequency = t.recurringFrequency;
      });
    } catch (e) {
      // not found
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onMerchantSelected(MerchantModel? merchant) {
    setState(() {
      _selectedMerchant = merchant;
      if (merchant != null) {
        _selectedCategoryId = merchant.categoryId;
        if (merchant.typicalAmount != null && _amountController.text.isEmpty) {
          _amountController.text = merchant.typicalAmount.toString();
        }
        if (merchant.paymentMode != null) {
          _paymentMode = merchant.paymentMode!;
        }
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final t = TransactionModel(
      id: _isEditing ? _editingTransaction!.id : const Uuid().v4(),
      type: _type,
      amount: amount,
      categoryId: _selectedCategoryId!,
      title: _titleController.text.isEmpty ? null : _titleController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: _date,
      paymentMode: _paymentMode,
      isRecurring: _isRecurring,
      recurringFrequency: _isRecurring ? _recurringFrequency : null,
      createdAt: _isEditing ? _editingTransaction!.createdAt : DateTime.now(),
    );

    if (_isEditing) {
      await ref
          .read(transactionsControllerProvider.notifier)
          .updateTransaction(t);
    } else {
      await ref.read(transactionsControllerProvider.notifier).addTransaction(t);
      if (_selectedMerchant != null) {
        await ref
            .read(merchantsControllerProvider.notifier)
            .incrementUsage(_selectedMerchant!.id);
      }
    }

    if (mounted) context.pop();
  }

  Future<void> _deleteTransaction() async {
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Transaction',
      content: 'Are you sure you want to delete this transaction?',
      isDestructive: true,
      confirmText: 'Delete',
    );

    if (confirm && mounted) {
      await ref
          .read(transactionsControllerProvider.notifier)
          .deleteTransaction(_editingTransaction!.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final filteredCategories =
              categories.where((c) => c.type == _type).toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Type Selector
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'expense', label: Text('Expense')),
                    ButtonSegment(value: 'income', label: Text('Income')),
                    ButtonSegment(value: 'savings', label: Text('Savings')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) {
                    setState(() {
                      _type = set.first;
                      _selectedCategoryId =
                          null; // Reset category when type changes
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ).merge(
                    ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(WidgetState.selected)) {
                          if (_type == 'expense')
                            return AppColors.expense.withOpacity(0.2);
                          if (_type == 'income')
                            return AppColors.income.withOpacity(0.2);
                          return AppColors.savings.withOpacity(0.2);
                        }
                        return null;
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: _type == 'expense'
                        ? AppColors.expense
                        : (_type == 'income'
                            ? AppColors.income
                            : AppColors.savings),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter amount';
                    if (double.tryParse(val) == null)
                      return 'Enter valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Merchant Autocomplete (only for expense)
                if (_type == 'expense') ...[
                  MerchantAutocomplete(
                    onMerchantSelected: _onMerchantSelected,
                    initialValue: _titleController.text,
                  ),
                  const SizedBox(height: 20),
                ],

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title / Note',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Selection
                const Text('Category',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = filteredCategories[index];
                    final isSelected = _selectedCategoryId == cat.id;
                    final catColor = CategoryColorUtils.fromHex(cat.color);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? catColor.withOpacity(0.2)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? catColor : theme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CategoryIconUtils.fromHex(cat.icon),
                              color:
                                  isSelected ? catColor : theme.iconTheme.color,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat.name,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Date & Payment Mode Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(DateFormatter.formatShort(_date)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Other']
                                .contains(_paymentMode)
                            ? _paymentMode
                            : 'UPI',
                        decoration: const InputDecoration(
                          labelText: 'Mode',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Other']
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _paymentMode = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recurring Toggle
                SwitchListTile(
                  title: const Text('Recurring Transaction'),
                  subtitle: const Text('Auto-add this transaction on schedule'),
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val),
                  contentPadding: EdgeInsets.zero,
                ),

                if (_isRecurring) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _recurringFrequency ?? 'monthly',
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: ['daily', 'weekly', 'monthly', 'yearly']
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _recurringFrequency = val);
                    },
                  ),
                ],

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Transaction',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
