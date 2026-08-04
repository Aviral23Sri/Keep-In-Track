import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_color_utils.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/providers/category_providers.dart';

class CategoryDonutBreakdown extends ConsumerStatefulWidget {
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;
  final double totalExpense;
  final double totalIncome;

  const CategoryDonutBreakdown({
    super.key,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.totalExpense,
    required this.totalIncome,
  });

  @override
  ConsumerState<CategoryDonutBreakdown> createState() =>
      _CategoryDonutBreakdownState();
}

class _CategoryDonutBreakdownState
    extends ConsumerState<CategoryDonutBreakdown> {
  int _touchedIndex = -1;
  bool _showExpense = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    final data = _showExpense ? widget.expensesByCategory : widget.incomeByCategory;
    final total = _showExpense ? widget.totalExpense : widget.totalIncome;

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
          // ── Header + Toggle ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  'By Category',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _ToggleChip(
                        label: 'Expense',
                        selected: _showExpense,
                        color: AppColors.expense,
                        onTap: () => setState(() {
                          _showExpense = true;
                          _touchedIndex = -1;
                        }),
                      ),
                      _ToggleChip(
                        label: 'Income',
                        selected: !_showExpense,
                        color: AppColors.income,
                        onTap: () => setState(() {
                          _showExpense = false;
                          _touchedIndex = -1;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (total == 0)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No ${_showExpense ? "expense" : "income"} data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color),
                ),
              ),
            )
          else
            categoriesAsync.when(
              data: (categories) {
                final entries = data.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                // Build color + name map
                final catColors = <String, Color>{};
                final catNames = <String, String>{};
                for (final e in entries) {
                  final cat = categories.cast<dynamic>().firstWhere(
                      (c) => c.id == e.key,
                      orElse: () => null);
                  catColors[e.key] = cat != null
                      ? CategoryColorUtils.fromHex(cat.color as String)
                      : AppColors.chartColors[
                          entries.indexOf(e) % AppColors.chartColors.length];
                  catNames[e.key] = cat?.name as String? ?? 'Unknown';
                }

                return Column(
                  children: [
                    // Donut chart
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response?.touchedSection == null) {
                                  _touchedIndex = -1;
                                } else {
                                  _touchedIndex = response!
                                      .touchedSection!.touchedSectionIndex;
                                }
                              });
                            },
                          ),
                          centerSpaceRadius: 48,
                          sectionsSpace: 2,
                          sections: entries.asMap().entries.map((me) {
                            final i = me.key;
                            final e = me.value;
                            final isTouched = i == _touchedIndex;
                            final pct = (e.value / total * 100);
                            return PieChartSectionData(
                              color: catColors[e.key]!,
                              value: e.value,
                              title: isTouched
                                  ? '${pct.toStringAsFixed(0)}%'
                                  : '',
                              radius: isTouched ? 68 : 56,
                              titleStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Category list with progress bars
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Column(
                        children: entries.asMap().entries.map((me) {
                          final i = me.key;
                          final e = me.value;
                          final pct = e.value / total;
                          final color = catColors[e.key]!;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _touchedIndex = i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          catNames[e.key]!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        '${(pct * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: theme.textTheme.bodySmall
                                                ?.color),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        CurrencyFormatter.formatCompact(
                                            e.value),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
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
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
