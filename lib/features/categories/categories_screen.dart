import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category_model.dart';
import '../../data/models/subcategory_model.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/subcategory_providers.dart';
import '../../core/utils/category_color_utils.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/gradient_app_bar.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategorySheet(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final expenses =
              categories.where((c) => c.type == 'expense').toList();
          final income = categories.where((c) => c.type == 'income').toList();
          final savings = categories.where((c) => c.type == 'savings').toList();

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Expenses'),
                    Tab(text: 'Income'),
                    Tab(text: 'Savings'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCategoryGrid(context, ref, expenses),
                      _buildCategoryGrid(context, ref, income),
                      _buildCategoryGrid(context, ref, savings),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> categories,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final catColor = CategoryColorUtils.fromHex(cat.color);
        final catIcon = CategoryIconUtils.fromHex(cat.icon);

        return InkWell(
          onTap: () => context.push('/category-transactions/${cat.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 28),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCategorySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCategorySheet(ref: ref),
    );
  }
}

// ── Available icons and colors for picker ─────────────────────────────────────

final _availableIcons = <IconData>[
  Icons.shopping_cart,
  Icons.restaurant,
  Icons.directions_car,
  Icons.home,
  Icons.local_hospital,
  Icons.school,
  Icons.sports_esports,
  Icons.movie,
  Icons.flight,
  Icons.fitness_center,
  Icons.pets,
  Icons.local_cafe,
  Icons.checkroom,
  Icons.savings,
  Icons.work,
  Icons.business,
  Icons.star,
  Icons.favorite,
  Icons.card_giftcard,
  Icons.receipt_long,
  Icons.attach_money,
  Icons.wallet,
  Icons.smartphone,
  Icons.electric_bolt,
  Icons.water_drop,
  Icons.wifi,
  Icons.local_gas_station,
  Icons.build,
  Icons.celebration,
  Icons.music_note,
];

final _availableColors = <Color>[
  const Color(0xFFEF5350),
  const Color(0xFFFF7043),
  const Color(0xFFFFA726),
  const Color(0xFFFFEE58),
  const Color(0xFF66BB6A),
  const Color(0xFF26C6DA),
  const Color(0xFF42A5F5),
  const Color(0xFF5C6BC0),
  const Color(0xFFAB47BC),
  const Color(0xFFEC407A),
  const Color(0xFF8D6E63),
  const Color(0xFF78909C),
  const Color(0xFF26A69A),
  const Color(0xFFD4E157),
  const Color(0xFF29B6F6),
];

// ── Add Category Sheet ─────────────────────────────────────────────────────────

class _AddCategorySheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddCategorySheet({required this.ref});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  final _subController = TextEditingController();

  String _type = 'expense';
  IconData _selectedIcon = Icons.star;
  Color _selectedColor = const Color(0xFF5C6BC0);

  final List<String> _subcategories = [];

  void _addSubcategory() {
    final text = _subController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subcategories.add(text);
      _subController.clear();
    });
  }

  void _removeSubcategory(int index) {
    setState(() => _subcategories.removeAt(index));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final catId = const Uuid().v4();
    final newCat = CategoryModel(
      id: catId,
      name: name,
      icon: CategoryIconUtils.code(_selectedIcon),
      color: CategoryColorUtils.code(_selectedColor),
      type: _type,
      isDefault: false,
    );

    await widget.ref
        .read(categoriesControllerProvider.notifier)
        .addCategory(newCat);

    // Add subcategories linked to the new category
    for (final subName in _subcategories) {
      final sub = SubcategoryModel(
        id: const Uuid().v4(),
        name: subName,
        categoryId: catId,
        isDefault: false,
      );
      await widget.ref
          .read(subcategoriesControllerProvider.notifier)
          .addSubcategory(sub);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              'Add Custom Category',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Category Name ──────────────────────────────────────────────
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // ── Type picker ────────────────────────────────────────────────
            Text('Type', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
                ButtonSegment(value: 'savings', label: Text('Savings')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // ── Icon picker ────────────────────────────────────────────────
            Text('Icon', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final icon = _availableIcons[i];
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.2)
                            : theme.cardColor,
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : theme.iconTheme.color,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── Color picker ───────────────────────────────────────────────
            Text('Color', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Preview ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_selectedIcon, color: _selectedColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  _nameController.text.isEmpty
                      ? 'Category preview'
                      : _nameController.text,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // ── Subcategories section ──────────────────────────────────────
            Text(
              'Subcategories (optional)',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Add subcategories to further organise transactions under this category.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),

            // Subcategory input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subController,
                    decoration: const InputDecoration(
                      labelText: 'Subcategory name',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addSubcategory(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addSubcategory,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),

            // List of added subcategories
            if (_subcategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(_subcategories.length, (i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.subdirectory_arrow_right,
                          size: 16, color: _selectedColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _subcategories[i],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeSubcategory(i),
                        child: Icon(Icons.close,
                            size: 18,
                            color: theme.textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 24),

            // ── Action buttons ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: Text(
                      _subcategories.isEmpty
                          ? 'Add Category'
                          : 'Add Category & ${_subcategories.length} Subcategor${_subcategories.length == 1 ? 'y' : 'ies'}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

