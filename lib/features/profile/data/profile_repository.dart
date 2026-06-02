import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/profile_model.dart';

class ProfileRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<TenantProfile>> getProfile() {
    return _client.get<TenantProfile>(
      ApiPaths.profile,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return TenantProfile.fromJson(payload);
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/tenant-mobile/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        return (root['data'] as Map<String, dynamic>?) ?? {};
      },
    );
  }
}
