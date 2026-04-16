import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/notification_model.dart';

class NotificationsRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<List<TenantNotification>>> getNotifications({String? flatId}) {
    final queryParams = flatId == null ? null : <String, dynamic>{'flatId': flatId};

    return _client.get<List<TenantNotification>>(
      ApiPaths.notifications,
      queryParams: queryParams,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        final list = (payload['items'] as List<dynamic>? ??
            payload['notifications'] as List<dynamic>? ??
            <dynamic>[]);
        return list
            .cast<Map<String, dynamic>>()
            .map(TenantNotification.fromJson)
            .toList();
      },
    );
  }
}
