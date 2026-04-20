import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/animations.dart';
import '../../core/constants/tenant_screens.dart';
import '../../features/auth/providers/auth_provider.dart';

typedef _TabDef = (String path, String label, IconData icon, String? screenKey);

class TabShell extends ConsumerWidget {
  const TabShell({required this.child, super.key});

  final Widget child;

  static const List<_TabDef> _allTabs = <_TabDef>[
    ('/dashboard', 'Dashboard', Icons.home_outlined, TenantScreens.dashboard),
    ('/history', 'History', Icons.history_outlined, TenantScreens.history),
    ('/documents', 'Docs', Icons.description_outlined, TenantScreens.documents),
    (
      '/notifications',
      'Alerts',
      Icons.notifications_outlined,
      TenantScreens.notifications
    ),
    ('/payment-page', 'Pay', Icons.payment_outlined, TenantScreens.paymentPage),
    ('/profile', 'Profile', Icons.person_outline, TenantScreens.profile),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledScreens =
        ref.watch(authProvider.select((s) => s.enabledScreens));
    final tabs = _allTabs
        .where((tab) => tab.$4 == null || enabledScreens.contains(tab.$4))
        .toList();

    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = tabs.indexWhere((tab) => location.startsWith(tab.$1));

    if (tabs.length < 2) {
      return Scaffold(body: child);
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppAnimations.normal,
        switchInCurve: AppAnimations.easeOutCubic,
        switchOutCurve: AppAnimations.easeInOutCubic,
        transitionBuilder: (switchChild, animation) {
          return RouteFadeSlideTransition(
            animation: animation,
            child: switchChild,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(location),
          child: child,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.violet,
              AppColors.violet.withOpacity(0.84),
            ],
          ),
          boxShadow: AppShadows.card(AppColors.violet),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          onTap: (index) => context.go(tabs[index].$1),
          items: tabs
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
