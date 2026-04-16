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
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return DashboardResponse.fromJson(payload);
      },
    );
  }
}
