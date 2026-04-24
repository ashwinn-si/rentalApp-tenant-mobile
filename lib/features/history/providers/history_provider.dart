import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/history_repository.dart';
import '../data/models/history_response.dart';

class HistoryParams {
  const HistoryParams({required this.page, this.flatId});

  final int page;
  final String? flatId;

  @override
  bool operator ==(Object other) {
    return other is HistoryParams &&
        other.page == page &&
        other.flatId == flatId;
  }

  @override
  int get hashCode => Object.hash(page, flatId);
}

final historyProvider =
    FutureProvider.family<HistoryResponse, HistoryParams>((ref, params) async {
  developer.log('[HistoryProvider] Loading history with page=${params.page}, flatId=${params.flatId}');

  try {
    final repository = HistoryRepository();
    final result = await repository.getHistory(page: params.page, flatId: params.flatId);

    developer.log('[HistoryProvider] Result - isSuccess=${result.isSuccess}, statusCode=${result.statusCode}, hasData=${result.data != null}, error=${result.error}');

    if (!result.isSuccess || result.data == null) {
      final error = result.error ?? 'Unable to load history (status: ${result.statusCode})';
      developer.log('[HistoryProvider] Throwing error: $error');
      throw Exception(error);
    }

    developer.log('[HistoryProvider] SUCCESS - items=${result.data!.items.length}, page=${result.data!.page}, totalPages=${result.data!.totalPages}');
    return result.data!;
  } catch (e, stack) {
    developer.log('[HistoryProvider] CAUGHT EXCEPTION: $e\n$stack');
    rethrow;
  }
});

final activeHistoryProvider =
    FutureProvider.family<HistoryResponse, int>((ref, page) {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  developer.log('[ActiveHistoryProvider] Watching history for page=$page, activeFlatId=$flatId');
  return ref
      .watch(historyProvider(HistoryParams(page: page, flatId: flatId)).future);
});
