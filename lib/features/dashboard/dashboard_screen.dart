import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import '../../shared/providers/dashboard_providers.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/providers/pending_sms_providers.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/summary_card.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/budget_status_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final transactionsAsync = ref.watch(transactionsControllerProvider);

    return Scaffold(
      appBar: const GradientAppBar(
        title: Text('Dashboard'),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: summaryAsync.when(
              data: (summary) => _buildSummaryCards(summary),
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          
          // ── Pending SMS Banner ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer(
              builder: (ctx, r, _) {
                final count = r.watch(pendingSmsCountProvider);
                if (count == 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: InkWell(
                    onTap: () => context.push('/pending-review'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.75),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.sms_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$count transaction${count > 1 ? "s" : ""} detected via SMS',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  'Tap to review and log',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Quick Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: BudgetStatusBar(),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),



          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () => context.push('/transactions'),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No transactions yet.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                );
              }
              final recent = transactions.take(10).toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final t = recent[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: TransactionTile(transaction: t)
                          .animate()
                          .fade(delay: (50 * index).ms)
                          .slideX(begin: 0.2, end: 0),
                    );
                  },
                  childCount: recent.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DashboardSummary summary) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          SummaryCard(
            title: 'Total Balance',
            amount: summary.balance,
            gradientName: 'balance',
            icon: Icons.account_balance_wallet,
          ),
          SummaryCard(
            title: 'Total Income',
            amount: summary.totalIncome,
            gradientName: 'income',
            icon: Icons.trending_up,
          ),
          SummaryCard(
            title: 'Total Expense',
            amount: summary.totalExpense,
            gradientName: 'expense',
            icon: Icons.trending_down,
          ),
          SummaryCard(
            title: 'Total Savings',
            amount: summary.totalSavings,
            gradientName: 'savings',
            icon: Icons.savings,
          ),
        ],
      ).animate().fade().slideX(begin: 0.1, end: 0),
    );
  }
}
