import 'package:dio/dio.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import './models/maintenance_issue.dart';

class MaintenanceRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<MaintenanceIssuesResponse>> getIssues({String? status}) {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;

    return _client.get<MaintenanceIssuesResponse>(
      ApiPaths.maintenanceIssues,
      queryParams: query,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return MaintenanceIssuesResponse.fromJson(payload);
      },
    );
  }

  Future<ApiResponse<MaintenanceIssue>> getIssue(String issueId) {
    return _client.get<MaintenanceIssue>(
      '${ApiPaths.maintenanceIssues}/$issueId',
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return MaintenanceIssue.fromJson(payload);
      },
    );
  }

  Future<ApiResponse<MaintenanceIssue>> createIssue({
    required String apartmentId,
    required String flatId,
    required String scope,
    required String title,
    required String description,
    required String category,
    num? tenantRepairCost,
    required List<String> imagePaths,
  }) async {
    final formData = FormData.fromMap({
      'apartmentId': apartmentId,
      'flatId': flatId,
      'scope': scope,
      'title': title,
      'description': description,
      'category': category,
      if (tenantRepairCost != null) 'tenantRepairCost': tenantRepairCost,
    });

    for (final path in imagePaths) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(path),
      ));
    }

    return _client.post<MaintenanceIssue>(
      '${ApiPaths.maintenanceIssues}/create',
      data: formData,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return MaintenanceIssue.fromJson(payload);
      },
    );
  }
}
