import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_color_utils.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/providers/category_providers.dart';

class TopTransactionsCard extends ConsumerWidget {
  final List<TransactionModel> topExpenses;

  const TopTransactionsCard({super.key, required this.topExpenses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    if (topExpenses.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.expense, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Top Expenses',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          categoriesAsync.when(
            data: (categories) {
              return Column(
                children: topExpenses.asMap().entries.map((entry) {
                  final i = entry.key;
                  final t = entry.value;
                  final cat = categories.cast<dynamic>().firstWhere(
                      (c) => c.id == t.categoryId, orElse: () => null);
                  final catColor = cat != null
                      ? CategoryColorUtils.fromHex(cat.color as String)
                      : AppColors.chartColors[i % AppColors.chartColors.length];
                  final catName = cat?.name as String? ?? 'Unknown';

                  return Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: isDark ? 0.1 : 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: catColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title ?? t.merchantName ?? catName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      catName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: catColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('d MMM').format(t.date),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatCompact(t.amount),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
