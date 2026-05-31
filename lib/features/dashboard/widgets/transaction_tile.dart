import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/category_color_utils.dart';
import '../../../core/utils/category_icon_utils.dart';
import '../../../shared/providers/category_providers.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => categories.first, // Fallback
        );

        final catColor = CategoryColorUtils.fromHex(category.color);
        final IconData catIcon = CategoryIconUtils.fromHex(category.icon);

        Color amountColor;
        if (transaction.type == 'income') {
          amountColor = AppColors.income;
        } else if (transaction.type == 'savings')
          amountColor = AppColors.savings;
        else
          amountColor = theme.textTheme.bodyLarge!.color!;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title ?? category.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.name} • ${DateFormatter.formatShort(transaction.date)}',
                        style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.formatWithSign(
                            transaction.amount, transaction.type),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: amountColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (transaction.isRecurring) ...[
                        const SizedBox(height: 4),
                        Icon(Icons.repeat,
                            size: 14, color: theme.textTheme.bodySmall?.color),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 72),
      error: (_, __) => const SizedBox(height: 72),
    );
  }
}
