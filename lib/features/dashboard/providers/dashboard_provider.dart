import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_response.dart';

final dashboardProvider = FutureProvider.family<DashboardResponse, String?>((ref, flatId) async {
  final repository = DashboardRepository();
  final result = await repository.getDashboard(flatId: flatId);
  if (!result.isSuccess || result.data == null) {
    throw Exception(result.error ?? 'Unable to load dashboard');
  }
  return result.data!;
});

final activeDashboardProvider = FutureProvider<DashboardResponse>((ref) {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  return ref.watch(dashboardProvider(flatId).future);
});
