class TenantDocument {
  const TenantDocument(
      {required this.id,
      required this.fileName,
      required this.url,
      required this.uploadedAt});

  final String id;
  final String fileName;
  final String url;
  final String uploadedAt;

  static String _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      final normalized = value.toString().trim();
      if (normalized.isNotEmpty && normalized.toLowerCase() != 'null') {
        return normalized;
      }
    }

    return '';
  }

  factory TenantDocument.fromJson(Map<String, dynamic> json) {
    return TenantDocument(
      id: _pickString(json, <String>['id', 'documentId', 's3Key']),
      fileName: _pickString(json, <String>['fileName', 'name']).isEmpty
          ? 'Document'
          : _pickString(json, <String>['fileName', 'name']),
      url: _pickString(
        json,
        <String>['url', 'signedUrl', 's3Url', 'downloadUrl', 'fileUrl'],
      ),
      uploadedAt:
          (json['uploadedAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
