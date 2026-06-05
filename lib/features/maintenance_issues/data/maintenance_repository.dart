import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/image_utils.dart';
import './models/maintenance_issue.dart';

const _uploadSendTimeout = Duration(seconds: 120);
const _uploadReceiveTimeout = Duration(seconds: 120);

class MaintenanceRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<MaintenanceIssuesResponse>> getIssues({
    String? status,
    int page = 1,
    int limit = 10,
  }) {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    query['skip'] = (page - 1) * limit;
    query['limit'] = limit;

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
      final raw = await File(path).readAsBytes();
      final Uint8List finalBytes = ImageUtils.isCompressible(path)
          ? await ImageUtils.compressBytes(raw)
          : raw;
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(finalBytes, filename: path.split('/').last),
      ));
    }

    return _client.post<MaintenanceIssue>(
      '${ApiPaths.maintenanceIssues}/create',
      data: formData,
      sendTimeout: _uploadSendTimeout,
      receiveTimeout: _uploadReceiveTimeout,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return MaintenanceIssue.fromJson(payload);
      },
    );
  }
}
