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

    return _client.get<HistoryResponse>(
      ApiPaths.history,
      queryParams: query,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return HistoryResponse.fromJson(payload);
      },
    );
  }
}
