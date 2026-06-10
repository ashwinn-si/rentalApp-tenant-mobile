import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/image_utils.dart';
import 'models/bug_reports_model.dart';

const _uploadSendTimeout = Duration(seconds: 120);
const _uploadReceiveTimeout = Duration(seconds: 120);

class BugReportsRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<List<BugReport>>> getBugReports() {
    return _client.get<List<BugReport>>(
      ApiPaths.bugReports,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final data = (root['data'] as List<dynamic>?) ?? [];
        return data
            .cast<Map<String, dynamic>>()
            .map(BugReport.fromJson)
            .toList();
      },
    );
  }

  Future<ApiResponse<BugReportsResponseDto>> getBugReportsWithPagination({
    String? status,
    int page = 1,
    int limit = 10,
  }) {
    return _client.get<BugReportsResponseDto>(
      ApiPaths.bugReports,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        return BugReportsResponseDto.fromJson(root);
      },
      queryParams: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<ApiResponse<BugReport>> getBugReport(String bugReportId) {
    return _client.get<BugReport>(
      '${ApiPaths.bugReports}/$bugReportId',
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return BugReport.fromJson(payload);
      },
    );
  }

  Future<ApiResponse<BugReport>> submitBugReport({
    required String title,
    required String description,
    required String type,
    required List<File> images,
  }) async {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('type', type),
    ]);

    for (final file in images) {
      final raw = await file.readAsBytes();
      final Uint8List finalBytes = ImageUtils.isCompressible(file.path)
          ? await ImageUtils.compressBytes(raw)
          : raw;
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(finalBytes, filename: file.path.split('/').last),
      ));
    }

    return _client.post<BugReport>(
      ApiPaths.bugReports,
      data: formData,
      sendTimeout: _uploadSendTimeout,
      receiveTimeout: _uploadReceiveTimeout,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return BugReport.fromJson(payload);
      },
    );
  }
}
