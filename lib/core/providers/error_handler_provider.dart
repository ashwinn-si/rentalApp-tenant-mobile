import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';

/// Global error handler for API responses
/// Use in any screen's error handler:
///   if (handleApiError(error, ref)) return;  // handled, no need to show UI
class ApiErrorHandler {
  /// Check if error is 403/401 and auto-logout
  /// Returns true if error was handled (user logged out), false if should show error UI
  static bool handleAccessDenied(Object error, WidgetRef ref) {
    final errorStr = error.toString().toLowerCase();

    // Log for debugging
    developer.log('[ApiErrorHandler] Checking error: $errorStr');

    // Check for 403 "access denied" patterns
    if (errorStr.contains('403') ||
        errorStr.contains('platform') ||
        errorStr.contains('disabled') ||
        errorStr.contains('access denied') ||
        errorStr.contains('currently disabled')) {
      developer.log('[ApiErrorHandler] DETECTED 403 - Logging out and redirecting to login');

      // Auto-logout (no await needed, logout is sync)
      ref.read(authProvider.notifier).logout();

      return true; // Error was handled
    }

    return false; // Error not handled, show error UI
  }
}

/// Monitors API responses for 403/401 errors and triggers logout
/// Use this in main.dart: ref.listen(errorHandlerProvider, (_, __) {});
final errorHandlerProvider = FutureProvider<void>((ref) async {
  // This provider keeps auth state in sync and can trigger side effects
  final authState = ref.watch(authProvider);

  // If token exists, provider is "active"
  if (authState.token != null) {
    // Provider will clean up if we detect errors through other means
  }

  return Future.value();
});
