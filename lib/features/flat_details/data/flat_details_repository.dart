import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/flat_details_model.dart';

class FlatDetailsRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<FlatDetailsResponse>> getFlatDetails({String? flatId}) {
    final params = flatId != null ? {'flatId': flatId} : <String, dynamic>{};
    return _client.get<FlatDetailsResponse>(
      ApiPaths.flatDetails,
      queryParams: params,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return FlatDetailsResponse.fromJson(payload);
      },
    );
  }
}
