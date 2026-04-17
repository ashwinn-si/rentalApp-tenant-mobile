import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_paths.dart';
import 'models/app_version_model.dart';

class AppVersionRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<AppVersionModel>> getCurrentVersion() {
    return _client.get<AppVersionModel>(
      ApiPaths.currentAppVersion,
      fromJson: (json) =>
          AppVersionModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
