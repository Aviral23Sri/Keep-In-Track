import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/pending_sms_providers.dart';
import '../../core/services/sms_parser.dart';
import '../../shared/widgets/gradient_app_bar.dart';

class PendingReviewScreen extends ConsumerWidget {
  const PendingReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingSmsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const GradientAppBar(
        title: Text('Pending Review'),
        centerTitle: false,
      ),
      body: pendingAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 72,
                      color: AppColors.success.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('All caught up!',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('No pending transactions to review.',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                _PendingTile(txn: list[i], isDark: isDark),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ── Individual tile ───────────────────────────────────────────────────────────

class _PendingTile extends ConsumerWidget {
  final ParsedSmsTransaction txn;
  final bool isDark;

  const _PendingTile({required this.txn, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme      = Theme.of(context);
    final isExpense  = txn.type == 'expense';
    final typeColor  = isExpense ? AppColors.expense : AppColors.income;
    final typeIcon   = isExpense
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: typeColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + amount + date ────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.merchant ?? (isExpense ? 'Expense' : 'Income'),
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _ModeChip(mode: txn.paymentMode),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMM, hh:mm a')
                              .format(txn.detectedAt),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '₹${txn.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: typeColor,
                ),
              ),
            ],
          ),

          // ── Raw SMS preview ───────────────────────────────────────────────
          if (txn.rawBody.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                txn.rawBody,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Action buttons ────────────────────────────────────────────────
          Row(
            children: [
              // Dismiss
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(pendingSmsProvider.notifier)
                        .dismiss(txn.id);
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Dismiss'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textTheme.bodySmall?.color,
                    side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Add as transaction
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    context.push(
                      '/add-transaction'
                      '?amount=${txn.amount}'
                      '&type=${txn.type}'
                      '&paymentMode=${Uri.encodeComponent(txn.paymentMode)}'
                      '&date=${txn.detectedAt.millisecondsSinceEpoch}'
                      '&pendingId=${txn.id}',
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Transaction'),
                  style: FilledButton.styleFrom(
                    backgroundColor: typeColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Payment mode chip ─────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String mode;
  const _ModeChip({required this.mode});

  static const _labels = {
    'upi': 'UPI',
    'card': 'Card',
    'cash': 'Cash',
    'bankTransfer': 'Bank',
  };
  static const _icons = {
    'upi': Icons.phone_android_rounded,
    'card': Icons.credit_card_rounded,
    'cash': Icons.money_rounded,
    'bankTransfer': Icons.account_balance_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final label = _labels[mode] ?? mode;
    final icon  = _icons[mode] ?? Icons.payment_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
