import 'dart:developer' as developer;

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/dashboard_response.dart';

class DashboardRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<DashboardResponse>> getDashboard({String? flatId}) {
    return _client.get<DashboardResponse>(
      ApiPaths.dashboard,
      queryParams: flatId == null ? null : <String, dynamic>{'flatId': flatId},
      fromJson: (json) {
        developer.log('[Dashboard] Raw API Response: $json');

        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;

        developer.log('[Dashboard] Extracted Payload: $payload');

        try {
          final response = DashboardResponse.fromJson(payload);
          developer.log('[Dashboard] Parsed Response: availableFlats=${response.availableFlats.length}, totalOutstanding=${response.totalOutstanding}');
          return response;
        } catch (e, stack) {
          developer.log('[Dashboard] Parsing Error: $e\n$stack');
          rethrow;
        }
      },
    ).then((result) {
      developer.log('[Dashboard] Final Result - isSuccess=${result.isSuccess}, hasData=${result.data != null}, error=${result.error}');
      return result;
    });
  }
}
