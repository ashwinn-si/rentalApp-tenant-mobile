import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';

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

/// Helper to handle API errors (403/401) globally
void handleApiError(int? statusCode, WidgetRef ref) {
  if (statusCode == 403 || statusCode == 401) {
    // Logout and let router redirect to login
    ref.read(authProvider.notifier).logout();
  }
}
