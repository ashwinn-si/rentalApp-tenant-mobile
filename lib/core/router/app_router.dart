import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/documents/screens/documents_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../utils/screen_navigation.dart';
import 'tab_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Only recreate router on auth-relevant changes, not isLoading
  ref.watch(
    authProvider.select((s) => (s.token, s.mustChangePassword, s.enabledScreens)),
  );
  final authState = ref.read(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = authState.token != null;
      final mustChangePassword = authState.mustChangePassword;
      final location = state.matchedLocation;

      if (location == '/splash') {
        // Authenticated users skip splash entirely
        if (isAuth && !mustChangePassword) {
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
      if (isAuth && !mustChangePassword && (location == '/login' || location == '/change-password')) {
        return getFirstEnabledScreenRoute(authState.enabledScreens);
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
      ShellRoute(
        builder: (context, state, child) => TabShell(child: child),
        routes: <RouteBase>[
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          GoRoute(path: '/documents', builder: (_, __) => const DocumentsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
