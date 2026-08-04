import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/reports_providers.dart';

class MonthNavigator extends StatelessWidget {
  final ReportViewMode viewMode;
  final DateTime selectedMonth;
  final ValueChanged<ReportViewMode> onViewModeChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool canGoNext;

  const MonthNavigator({
    super.key,
    required this.viewMode,
    required this.selectedMonth,
    required this.onViewModeChanged,
    required this.onPrev,
    required this.onNext,
    required this.canGoNext,
  });

  String _headerLabel() {
    switch (viewMode) {
      case ReportViewMode.weekly:
        return 'Week of ${DateFormat('d MMM').format(selectedMonth)}';
      case ReportViewMode.monthly:
        return DateFormat('MMMM yyyy').format(selectedMonth);
      case ReportViewMode.yearly:
        return selectedMonth.year.toString();
      case ReportViewMode.custom:
        return DateFormat('MMMM yyyy').format(selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // ── View Mode Tabs ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: ReportViewMode.values.where((m) => m != ReportViewMode.custom).map((mode) {
                  final isSelected = viewMode == mode;
                  final label = switch (mode) {
                    ReportViewMode.weekly => 'Week',
                    ReportViewMode.monthly => 'Month',
                    ReportViewMode.yearly => 'Year',
                    _ => '',
                  };
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onViewModeChanged(mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Month Arrow Nav ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  iconSize: 28,
                  onPressed: onPrev,
                  color: AppColors.primary,
                ),
                Text(
                  _headerLabel(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded,
                      color: canGoNext
                          ? AppColors.primary
                          : theme.disabledColor),
                  iconSize: 28,
                  onPressed: canGoNext ? onNext : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
