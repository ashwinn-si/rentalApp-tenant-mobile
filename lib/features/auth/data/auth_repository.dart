import 'package:flutter/foundation.dart';
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
        debugPrint('Login API Response: $json');
        final Map<String, dynamic> responseMap = json as Map<String, dynamic>;

        // Extract data from wrapper if present
        // Backend returns: {success, data, message}
        final dataMap = responseMap['data'] ?? responseMap;

        return LoginResponse.fromJson(dataMap as Map<String, dynamic>);
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
      fromJson: (json) {
        debugPrint('Change Password API Response: $json');
        final Map<String, dynamic> responseMap = json as Map<String, dynamic>;

        // Extract data from wrapper if present
        final dataMap = responseMap['data'] ?? responseMap;

        return dataMap as Map<String, dynamic>;
      },
    );
  }
}
