import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// We will import screens as they are built. For now, placeholders or dummy imports
import '../../features/auth/splash_screen.dart';
import '../../features/auth/lock_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/transactions/transaction_list_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/categories/category_transactions_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/merchant_manager_screen.dart';
import '../../features/settings/pin_setup_screen.dart';
import '../../shared/widgets/adaptive_scaffold.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddTransactionScreen(transactionId: id);
        },
      ),
      GoRoute(
        path: '/transactions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransactionListScreen(),
      ),
      GoRoute(
        path: '/category-transactions/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CategoryTransactionsScreen(
          categoryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/pin-setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/merchant-manager',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MerchantManagerScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdaptiveScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
