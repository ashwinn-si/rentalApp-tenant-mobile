import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_paths.dart';
import 'models/app_version_model.dart';

class AppVersionRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<AppVersionModel>> getCurrentVersion() {
    return _client.get<AppVersionModel>(
      ApiPaths.currentAppVersion,
      fromJson: (json) {
        debugPrint('App Version API Response: $json');
        final Map<String, dynamic> responseMap = json as Map<String, dynamic>;

        // Extract data from wrapper if present
        // Backend returns: {success, data, message}
        final dataMap = responseMap['data'] ?? responseMap;

        return AppVersionModel.fromJson(dataMap as Map<String, dynamic>);
      },
    );
  }
}
