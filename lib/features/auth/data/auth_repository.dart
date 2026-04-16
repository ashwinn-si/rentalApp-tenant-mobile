import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';

class AuthRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) {
    return _client.post<LoginResponse>(
      ApiPaths.login,
      data: request.toJson(),
      fromJson: (json) {
        return LoginResponse.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _client.post<Map<String, dynamic>>(
      ApiPaths.changePassword,
      data: <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
