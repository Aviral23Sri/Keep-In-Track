import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget child;

  const AdaptiveScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/budget')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        context.go('/budget');
        break;
      case 3:
        context.go('/reports');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Web layout (Wide)
        if (constraints.maxWidth >= 800) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (idx) => _onItemTapped(idx, context),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 16),
                    child: FloatingActionButton(
                      onPressed: () => context.push('/add-transaction'),
                      child: const Icon(Icons.add),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.category_outlined),
                      selectedIcon: Icon(Icons.category),
                      label: Text('Categories'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon: Icon(Icons.account_balance_wallet),
                      label: Text('Budget'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: Text('Reports'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        // Mobile layout (Narrow)
        return Scaffold(
          body: child,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton(
              onPressed: () => context.push('/add-transaction'),
              child: const Icon(Icons.add),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (idx) => _onItemTapped(idx, context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Budget',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
