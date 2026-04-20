import 'package:flutter/foundation.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'models/document_model.dart';

class DocumentsRepository {
  final DioClient _client = DioClient.instance;

  Future<ApiResponse<List<TenantDocument>>> getDocuments({String? flatId}) {
    final queryParams =
        flatId == null ? null : <String, dynamic>{'flatId': flatId};

    return _client.get<List<TenantDocument>>(
      ApiPaths.documents,
      queryParams: queryParams,
      fromJson: (json) {
        final root = json as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;

        final tenantDocs =
            (payload['tenantDocuments'] as List<dynamic>? ?? <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .map(TenantDocument.fromJson);

        final mappingDocs =
            (payload['mappingDocuments'] as List<dynamic>? ?? <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .expand((mapping) {
          final apartment = (mapping['apartment'] ?? '').toString().trim();
          final unit = (mapping['unit'] ?? '').toString().trim();
          final contextLabel =
              [apartment, unit].where((part) => part.isNotEmpty).join(' • ');

          final docs = (mapping['documents'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<String, dynamic>>();

          return docs.map((doc) {
            final mapped = Map<String, dynamic>.from(doc);
            if (contextLabel.isNotEmpty) {
              final baseName = (mapped['name'] ?? 'Document').toString();
              mapped['name'] = '$baseName ($contextLabel)';
            }
            return TenantDocument.fromJson(mapped);
          });
        });

        final documents = <TenantDocument>[...tenantDocs, ...mappingDocs];

        if (kDebugMode) {
          for (final doc in documents) {
            debugPrint('Documents API URL: ${doc.url}');
          }
        }

        return documents;
      },
    );
  }
}
