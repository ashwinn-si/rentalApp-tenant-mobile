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
  final repository = HistoryRepository();
  final result =
      await repository.getHistory(page: params.page, flatId: params.flatId);
  if (!result.isSuccess || result.data == null) {
    throw Exception(result.error ?? 'Unable to load history');
  }
  return result.data!;
});

final activeHistoryProvider =
    FutureProvider.family<HistoryResponse, int>((ref, page) {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  return ref
      .watch(historyProvider(HistoryParams(page: page, flatId: flatId)).future);
});
