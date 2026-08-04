import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class PaymentModeChart extends StatelessWidget {
  final Map<String, double> breakdown;
  final double totalExpense;

  const PaymentModeChart({
    super.key,
    required this.breakdown,
    required this.totalExpense,
  });

  static const Map<String, IconData> _icons = {
    'upi': Icons.phone_android_rounded,
    'cash': Icons.money_rounded,
    'card': Icons.credit_card_rounded,
    'bankTransfer': Icons.account_balance_rounded,
    'other': Icons.more_horiz_rounded,
  };

  static const Map<String, String> _labels = {
    'upi': 'UPI',
    'cash': 'Cash',
    'card': 'Card',
    'bankTransfer': 'Bank Transfer',
    'other': 'Other',
  };

  static const List<Color> _colors = [
    Color(0xFF4F46E5),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (breakdown.isEmpty || totalExpense == 0) return const SizedBox();

    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Payment Mode',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...entries.asMap().entries.map((me) {
            final i = me.key;
            final e = me.value;
            final color = _colors[i % _colors.length];
            final pct = totalExpense > 0 ? e.value / totalExpense : 0.0;
            final label = _labels[e.key] ?? e.key;
            final icon = _icons[e.key] ?? Icons.more_horiz_rounded;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(label,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              CurrencyFormatter.formatCompact(e.value),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 38,
                              child: Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct.toDouble(),
                            backgroundColor:
                                color.withValues(alpha: 0.12),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
