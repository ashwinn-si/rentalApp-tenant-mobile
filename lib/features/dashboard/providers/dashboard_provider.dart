import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_response.dart';

final dashboardProvider = FutureProvider.family<DashboardResponse, String?>((ref, flatId) async {
  developer.log('[DashboardProvider] Loading dashboard for flatId=$flatId');

  try {
    final repository = DashboardRepository();
    final result = await repository.getDashboard(flatId: flatId);

    developer.log('[DashboardProvider] Result - isSuccess=${result.isSuccess}, statusCode=${result.statusCode}, hasData=${result.data != null}, error=${result.error}');

    if (!result.isSuccess || result.data == null) {
      final error = result.error ?? 'Unable to load dashboard (status: ${result.statusCode})';
      developer.log('[DashboardProvider] Throwing error: $error');
      throw Exception(error);
    }

    developer.log('[DashboardProvider] SUCCESS - flats=${result.data!.availableFlats.length}, outstanding=${result.data!.totalOutstanding}');
    return result.data!;
  } catch (e, stack) {
    developer.log('[DashboardProvider] CAUGHT EXCEPTION: $e\n$stack');
    rethrow;
  }
});

final activeDashboardProvider = FutureProvider<DashboardResponse>((ref) {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  developer.log('[ActiveDashboardProvider] Watching dashboard for activeFlatId=$flatId');
  return ref.watch(dashboardProvider(flatId).future);
});
