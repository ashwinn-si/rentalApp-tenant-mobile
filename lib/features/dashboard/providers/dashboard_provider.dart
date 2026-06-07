import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_response.dart';
import '../data/models/outstanding_due_response.dart';
import '../data/models/rent_cards_response.dart';

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

final outstandingDueProvider = FutureProvider.family<OutstandingDueResponse, String?>((ref, flatId) async {
  try {
    final repository = DashboardRepository();
    final result = await repository.getOutstandingDue(flatId: flatId);

    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Unable to load outstanding due');
    }

    return result.data!;
  } catch (e) {
    developer.log('[OutstandingDueProvider] Error: $e');
    rethrow;
  }
});

final activeOutstandingDueProvider = FutureProvider<OutstandingDueResponse>((ref) {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  return ref.watch(outstandingDueProvider(flatId).future);
});

final rentCardsProvider = FutureProvider.family<RentCardsResponse, String?>((ref, flatId) async {
  developer.log('[RentCardsProvider] Loading rent cards for flatId=$flatId');

  try {
    final repository = DashboardRepository();
    final result = await repository.getRentCards(flatId: flatId);

    developer.log('[RentCardsProvider] Result - isSuccess=${result.isSuccess}, statusCode=${result.statusCode}, hasData=${result.data != null}, error=${result.error}');

    if (!result.isSuccess || result.data == null) {
      final error = result.error ?? 'Unable to load rent cards (status: ${result.statusCode})';
      developer.log('[RentCardsProvider] Throwing error: $error');
      throw Exception(error);
    }

    developer.log('[RentCardsProvider] SUCCESS - items=${result.data!.items.length}');
    return result.data!;
  } catch (e, stack) {
    developer.log('[RentCardsProvider] CAUGHT EXCEPTION: $e\n$stack');
    rethrow;
  }
});

final activeRentCardsProvider = FutureProvider<RentCardsResponse>((ref) {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  developer.log('[ActiveRentCardsProvider] Watching rent cards for activeFlatId=$flatId');
  return ref.watch(rentCardsProvider(flatId).future);
});
