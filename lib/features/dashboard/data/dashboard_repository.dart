import 'dart:developer' as developer;

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/dashboard_response.dart';
import 'models/outstanding_due_response.dart';
import 'models/rent_cards_response.dart';

class DashboardRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<DashboardResponse>> getDashboard({String? flatId}) {
    return _client.get<DashboardResponse>(
      '${ApiPaths.dashboard}/current',
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

  Future<ApiResponse<OutstandingDueResponse>> getOutstandingDue({String? flatId}) {
    return _client.get<OutstandingDueResponse>(
      '/tenant-mobile/outstanding-due',
      queryParams: flatId == null ? null : <String, dynamic>{'flatId': flatId},
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;

        return OutstandingDueResponse.fromJson(payload);
      },
    );
  }

  Future<ApiResponse<RentCardsResponse>> getRentCards({String? flatId}) {
    return _client.get<RentCardsResponse>(
      '${ApiPaths.dashboard}/cards',
      queryParams: flatId == null ? null : <String, dynamic>{'flatId': flatId},
      fromJson: (json) {
        developer.log('[RentCards] Raw API Response: $json');

        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;

        developer.log('[RentCards] Extracted Payload: $payload');

        try {
          final response = RentCardsResponse.fromJson(payload);
          developer.log('[RentCards] Parsed Response: items=${response.items.length}');
          return response;
        } catch (e, stack) {
          developer.log('[RentCards] Parsing Error: $e\n$stack');
          rethrow;
        }
      },
    ).then((result) {
      developer.log('[RentCards] Final Result - isSuccess=${result.isSuccess}, hasData=${result.data != null}, error=${result.error}');
      return result;
    });
  }
}
