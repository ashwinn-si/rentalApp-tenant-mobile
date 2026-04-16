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

  factory TenantDocument.fromJson(Map<String, dynamic> json) {
    return TenantDocument(
      id: (json['id'] ?? json['s3Key'] ?? '').toString(),
      fileName: (json['fileName'] ?? json['name'] ?? 'Document').toString(),
      url: (json['url'] ?? '').toString(),
      uploadedAt:
          (json['uploadedAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
