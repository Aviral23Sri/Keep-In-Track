import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category_model.dart';
import '../../shared/providers/category_providers.dart';
import '../../core/utils/category_color_utils.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../shared/widgets/gradient_app_bar.dart';
// import '../../shared/widgets/confirmation_dialog.dart'; // Removed as deletion is now handled in the category transactions screen

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
            onPressed: () => _showAddCategoryDialog(context, ref),
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
        final isCustom = !cat.isDefault;

        return InkWell(
          onTap: () => context.push('/category-transactions/${cat.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
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
                        color: catColor.withOpacity(0.2),
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
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    String name = '';
    String type = 'expense';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Category Name'),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'savings', child: Text('Savings')),
                ],
                onChanged: (val) {
                  if (val != null) type = val;
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.trim().isEmpty) return;

                final newCat = CategoryModel(
                  id: const Uuid().v4(),
                  name: name.trim(),
                  icon: CategoryIconUtils.code(Icons.star),
                  color: CategoryColorUtils.code(Colors.deepPurple),
                  type: type,
                  isDefault: false,
                );

                ref
                    .read(categoriesControllerProvider.notifier)
                    .addCategory(newCat);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
