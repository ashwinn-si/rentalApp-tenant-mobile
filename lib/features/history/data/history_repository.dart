import 'dart:developer' as developer;

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/history_response.dart';

class HistoryRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<HistoryResponse>> getHistory({
    required int page,
    String? flatId,
  }) {
    final query = <String, dynamic>{'page': page};
    if (flatId != null && flatId.isNotEmpty && flatId != 'all') {
      query['flatId'] = flatId;
    }

    developer.log('[History] Fetching with params: page=$page, flatId=$flatId, query=$query');

    return _client.get<HistoryResponse>(
      ApiPaths.history,
      queryParams: query,
      fromJson: (json) {
        developer.log('[History] Raw API Response: $json');

        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;

        developer.log('[History] Extracted Payload: $payload');

        try {
          final response = HistoryResponse.fromJson(payload);
          developer.log('[History] Parsed Response: items=${response.items.length}, page=${response.page}, totalPages=${response.totalPages}');
          return response;
        } catch (e, stack) {
          developer.log('[History] Parsing Error: $e\n$stack');
          rethrow;
        }
      },
    ).then((result) {
      developer.log('[History] Final Result - isSuccess=${result.isSuccess}, hasData=${result.data != null}, error=${result.error}');
      return result;
    });
  }

  Future<ApiResponse<HistoryItem>> getHistoryMonth({
    required int month,
    required int year,
    String? flatId,
  }) {
    final query = <String, dynamic>{};
    if (flatId != null && flatId.isNotEmpty && flatId != 'all') {
      query['flatId'] = flatId;
    }

    developer.log('[History] Fetching month: month=$month, year=$year, flatId=$flatId');

    return _client.get<HistoryItem>(
      '${ ApiPaths.history}/month/$month/$year',
      queryParams: query.isNotEmpty ? query : null,
      fromJson: (json) {
        developer.log('[History] Month Raw API Response: $json');

        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;

        developer.log('[History] Month Extracted Payload: $payload');

        try {
          final response = HistoryItem.fromJson(payload);
          developer.log('[History] Month Parsed Response: month=${response.monthLabel}, maintenanceBreakdownCount=${response.maintenanceBreakdownItems.length}');
          return response;
        } catch (e, stack) {
          developer.log('[History] Month Parsing Error: $e\n$stack');
          rethrow;
        }
      },
    ).then((result) {
      developer.log('[History] Month Final Result - isSuccess=${result.isSuccess}, hasData=${result.data != null}, error=${result.error}');
      return result;
    });
  }
}
