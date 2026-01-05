import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: AppTheme.primaryGradientStart.withValues(alpha: 0.1),
          destinations: [
            NavigationDestination(
              icon: Icon(
                LucideIcons.home,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              selectedIcon: Icon(
                LucideIcons.home,
                color: AppTheme.primaryGradientStart,
                fill: 1.0,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                LucideIcons.barChart2,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              selectedIcon: Icon(
                LucideIcons.barChart2,
                color: AppTheme.primaryGradientStart,
                fill: 1.0,
              ),
              label: 'Statistics',
            ),
            NavigationDestination(
              icon: Icon(
                LucideIcons.user,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              selectedIcon: Icon(
                LucideIcons.user,
                color: AppTheme.primaryGradientStart,
                fill: 1.0,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
