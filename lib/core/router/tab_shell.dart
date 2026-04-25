import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/utils/animations.dart';
import '../../core/constants/tenant_screens.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/documents/providers/documents_provider.dart';
import '../../features/history/providers/history_provider.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../../features/payment_proof/providers/payment_proof_provider.dart';

typedef _TabDef = (String path, String label, IconData icon, String? screenKey);

class TabShell extends ConsumerStatefulWidget {
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
    (
      '/payment-proof',
      'Receipt',
      Icons.receipt_outlined,
      TenantScreens.paymentProof
    ),
    (
      '/maintenance/history',
      'Maintenance',
      Icons.build_circle_outlined,
      TenantScreens.maintenance
    ),
    ('/profile', 'Profile', Icons.person_outline, TenantScreens.profile),
  ];

  @override
  ConsumerState<TabShell> createState() => _TabShellState();
}

class _TabShellState extends ConsumerState<TabShell> {
  int _refreshTick = 0;
  String? _lastMatchedLocation;

  void _refreshAll() {
    // Invalidate tab-root data so the next watch refetches.
    ref.invalidate(dashboardProvider);
    ref.invalidate(activeDashboardProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(activeHistoryProvider);
    ref.invalidate(documentsProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(paymentProofsProvider);
  }

  void _bumpRefreshTick() {
    if (!mounted) return;
    setState(() => _refreshTick++);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabledScreens =
        ref.watch(authProvider.select((s) => s.enabledScreens));
    final tabs = TabShell._allTabs
        .where((tab) => tab.$4 == null || enabledScreens.contains(tab.$4))
        .toList();

    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = tabs.indexWhere((tab) => location.startsWith(tab.$1));

    if (_lastMatchedLocation != location) {
      _lastMatchedLocation = location;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshAll();
        _bumpRefreshTick();
      });
    }

    if (tabs.length < 2) {
      return Scaffold(
        body: KeyedSubtree(
          key: ValueKey<String>('tabShell:$location:$_refreshTick'),
          child: widget.child,
        ),
      );
    }

    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey<String>('tabShell:$location:$_refreshTick'),
        child: widget.child,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF19172A).withValues(alpha: 0.94)
                    : Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2C2745)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isDark
                    ? <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.18),
                          blurRadius: 22,
                          spreadRadius: -8,
                        ),
                      ]
                    : const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x140F172A),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs.asMap().entries.map(
                    (entry) {
                      final tabPath = entry.value.$1;

                      return _TabButton(
                        label: entry.value.$2,
                        icon: entry.value.$3,
                        selected:
                            (currentIndex < 0 ? 0 : currentIndex) == entry.key,
                        onTap: () {
                          _refreshAll();
                          _bumpRefreshTick();
                          context.go(tabPath);
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  static const double _itemWidth = 50;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedScale(
      scale: selected ? 1 : 0.985,
      duration: AppAnimations.fast,
      curve: AppAnimations.easeOutCubic,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x1F6D28D9),
                    Color(0x126D28D9),
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          border: Border.all(
            color: selected
                ? AppColors.violet.withValues(alpha: 0.24)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.violet.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: SizedBox(
            width: _itemWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? AppColors.violet
                      : isDark
                          ? const Color(0xFF9CA3AF)
                          : AppColors.textSecondary.withValues(alpha: 0.78),
                  size: 21,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? AppColors.violet
                        : isDark
                            ? const Color(0xFFD1D5DB)
                            : AppColors.textSecondary.withValues(alpha: 0.84),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: AppAnimations.fast,
                  width: selected ? 14 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.violet,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
