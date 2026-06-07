import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/reports_providers.dart';
import '../../../shared/providers/category_providers.dart';
import '../../../core/utils/category_color_utils.dart';
import '../../../core/utils/currency_formatter.dart';

class MiniDonutChart extends ConsumerWidget {
  const MiniDonutChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current month report data for the chart
    final reportAsync = ref.watch(reportDataProvider(ReportPeriod.monthly));
    final categoriesAsync = ref.watch(categoriesControllerProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: reportAsync.when(
        data: (report) {
          if (report.totalExpense == 0 || report.expensesByCategory.isEmpty) {
            return const SizedBox(
              height: 120,
              child: Center(child: Text('No expenses this month yet.')),
            );
          }

          // Sort expenses and get top 3
          final entries = report.expensesByCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final topEntries = entries.take(3).toList();

          return categoriesAsync.when(
            data: (categories) {
              return Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: topEntries.map((e) {
                          final cat = categories.firstWhere(
                            (c) => c.id == e.key,
                            orElse: () => categories.first,
                          );
                          final color = CategoryColorUtils.fromHex(cat.color);
                          return PieChartSectionData(
                            color: color,
                            value: e.value,
                            showTitle: false,
                            radius: 16,
                          );
                        }).toList(),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 800),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: topEntries.map((e) {
                        final cat = categories.firstWhere(
                          (c) => c.id == e.key,
                          orElse: () => categories.first,
                        );
                        final color = CategoryColorUtils.fromHex(cat.color);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatCompact(e.value),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(height: 120),
          );
        },
        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
