import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/documents/screens/documents_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/notifications/screens/enable_notifications_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/payment_proof/screens/payment_proof_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/maintenance_issues/screens/issue_history_screen.dart';
import '../../features/maintenance_issues/screens/report_issue_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../services/notification_permission_service.dart';
import '../utils/animations.dart';
import '../utils/screen_navigation.dart';
import 'tab_shell.dart';

CustomTransitionPage<void> _buildTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: AppAnimations.normal,
    reverseTransitionDuration: AppAnimations.fast,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      return RouteFadeSlideTransition(
        animation: animation,
        child: pageChild,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  // Only recreate router on auth-relevant changes, not isLoading
  ref.watch(
    authProvider
        .select((s) => (s.token, s.mustChangePassword, s.enabledScreens)),
  );
  final authState = ref.read(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isAuth = authState.token != null;
      final mustChangePassword = authState.mustChangePassword;
      final location = state.matchedLocation;

      if (location == '/splash') {
        // Authenticated users skip splash entirely
        if (isAuth && !mustChangePassword) {
          final hasNotifications = await NotificationPermissionService.isEnabled();
          if (!hasNotifications) return '/enable-notifications';
          return getFirstEnabledScreenRoute(authState.enabledScreens);
        }
        if (isAuth && mustChangePassword) {
          return '/change-password';
        }
        return null;
      }

      if (!isAuth && location != '/login') {
        return '/login';
      }
      if (isAuth && mustChangePassword && location != '/change-password') {
        return '/change-password';
      }
      if (isAuth && !mustChangePassword) {
        final hasNotifications = await NotificationPermissionService.isEnabled();
        if (!hasNotifications && location != '/enable-notifications') {
          return '/enable-notifications';
        }
        if (hasNotifications && location == '/enable-notifications') {
          return getFirstEnabledScreenRoute(authState.enabledScreens);
        }
      }
      if (isAuth &&
          !mustChangePassword &&
          (location == '/login' || location == '/change-password')) {
        return getFirstEnabledScreenRoute(authState.enabledScreens);
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/change-password',
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/enable-notifications',
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const EnableNotificationsScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => TabShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/documents',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const DocumentsScreen(),
            ),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/maintenance/history',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const IssueHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/maintenance/report',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const ReportIssueScreen(),
            ),
          ),
          GoRoute(
            path: '/payment-proof',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const PaymentProofScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
