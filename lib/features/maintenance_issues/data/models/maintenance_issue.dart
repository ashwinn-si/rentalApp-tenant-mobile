class MaintenanceIssueImage {
  const MaintenanceIssueImage({
    required this.name,
    required this.s3Key,
    required this.uploadedAt,
    this.url,
  });

  final String name;
  final String s3Key;
  final String uploadedAt;
  final String? url;

  factory MaintenanceIssueImage.fromJson(Map<String, dynamic> json) {
    return MaintenanceIssueImage(
      name: (json['name'] ?? '').toString(),
      s3Key: (json['s3Key'] ?? '').toString(),
      uploadedAt: (json['uploadedAt'] ?? '').toString(),
      url: json['url']?.toString(),
    );
  }
}

class MaintenanceIssue {
  const MaintenanceIssue({
    required this.id,
    required this.issueId,
    required this.title,
    required this.description,
    required this.category,
    required this.scope,
    required this.status,
    required this.tenantRepairCost,
    required this.adminRepairCost,
    required this.images,
    required this.createdAt,
    this.adminComments,
  });

  final String id;
  final String issueId;
  final String title;
  final String description;
  final String category;
  final String scope;
  final String status;
  final num tenantRepairCost;
  final num adminRepairCost;
  final List<MaintenanceIssueImage> images;
  final DateTime createdAt;
  final String? adminComments;

  factory MaintenanceIssue.fromJson(Map<String, dynamic> json) {
    return MaintenanceIssue(
      id: (json['_id'] ?? '').toString(),
      issueId: (json['issueId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      scope: (json['scope'] ?? 'flat').toString(),
      status: (json['status'] ?? 'submitted').toString(),
      tenantRepairCost: (json['tenantRepairCost'] ?? 0) as num,
      adminRepairCost: (json['adminRepairCost'] ?? 0) as num,
      images: (json['images'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) =>
              MaintenanceIssueImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      adminComments: json['adminComments']?.toString(),
    );
  }
}

class MaintenanceIssuesResponse {
  const MaintenanceIssuesResponse({
    required this.issues,
    required this.total,
  });

  final List<MaintenanceIssue> issues;
  final int total;

  factory MaintenanceIssuesResponse.fromJson(Map<String, dynamic> json) {
    final rawIssues = (json['issues'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return MaintenanceIssuesResponse(
      issues: rawIssues.map(MaintenanceIssue.fromJson).toList(),
      total: (json['total'] ?? 0) as int,
    );
  }

  factory MaintenanceIssuesResponse.empty() {
    return const MaintenanceIssuesResponse(issues: <MaintenanceIssue>[], total: 0);
  }
}
