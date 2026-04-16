import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';

class TabShell extends StatelessWidget {
  const TabShell({required this.child, super.key});

  final Widget child;

  static const List<(String path, String label, IconData icon)> _tabs =
      <(String, String, IconData)>[
        ('/dashboard', 'Dashboard', Icons.home_outlined),
        ('/history', 'History', Icons.history_outlined),
        ('/documents', 'Docs', Icons.description_outlined),
        ('/notifications', 'Alerts', Icons.notifications_outlined),
        ('/profile', 'Profile', Icons.person_outline),
      ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((tab) => location.startsWith(tab.$1));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.violet,
              AppColors.violet.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          onTap: (index) => context.go(_tabs[index].$1),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: _tabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Icon(tab.$3, size: 24),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(tab.$3, size: 24),
                  ),
                  label: tab.$2,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
