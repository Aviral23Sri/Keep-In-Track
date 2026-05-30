import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/category_color_utils.dart';
import '../../../shared/providers/category_providers.dart';

class ExpensePieChart extends ConsumerStatefulWidget {
  final Map<String, double> expensesByCategory;
  final double totalExpense;

  const ExpensePieChart(
      {super.key,
      required this.expensesByCategory,
      required this.totalExpense});

  @override
  ConsumerState<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends ConsumerState<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.totalExpense == 0) return const SizedBox();

    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: categoriesAsync.when(
        data: (categories) {
          final entries = widget.expensesByCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: entries.asMap().entries.map((mapEntry) {
                      final i = mapEntry.key;
                      final e = mapEntry.value;
                      final cat = categories
                          .cast<dynamic>()
                          .firstWhere((c) => c.id == e.key, orElse: () => null);
                      final color = cat != null
                          ? CategoryColorUtils.fromHex(cat.color)
                          : Colors.grey;

                      final isTouched = i == touchedIndex;
                      final fontSize = isTouched ? 16.0 : 12.0;
                      final radius = isTouched ? 60.0 : 50.0;
                      final percentage = (e.value / widget.totalExpense) * 100;

                      return PieChartSectionData(
                        color: color,
                        value: e.value,
                        title: '${percentage.toStringAsFixed(0)}%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    final cat = categories
                        .cast<dynamic>()
                        .firstWhere((c) => c.id == e.key, orElse: () => null);
                    final color = cat != null
                        ? CategoryColorUtils.fromHex(cat.color)
                        : Colors.grey;
                    final name = cat?.name ?? 'Unknown';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}
