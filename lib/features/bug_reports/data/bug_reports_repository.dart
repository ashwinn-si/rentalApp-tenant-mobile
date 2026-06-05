import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/bug_reports_model.dart';

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
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'type': type,
      'images': images
          .map((file) => MultipartFile.fromFileSync(file.path))
          .toList(),
    });

    return _client.post<BugReport>(
      ApiPaths.bugReports,
      data: formData,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        return BugReport.fromJson(payload);
      },
    );
  }
}
