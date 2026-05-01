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

class RefundDetails {
  const RefundDetails({
    required this.refundedAmount,
    this.refundMonth,
    this.refundYear,
  });

  final num refundedAmount;
  final int? refundMonth;
  final int? refundYear;

  factory RefundDetails.fromJson(Map<String, dynamic> json) {
    return RefundDetails(
      refundedAmount: (json['refundedAmount'] ?? 0) as num,
      refundMonth: json['refundMonth'] as int?,
      refundYear: json['refundYear'] as int?,
    );
  }
}

class AdjustmentDetails {
  const AdjustmentDetails({
    required this.amount,
    this.adjustmentMonth,
    this.adjustmentYear,
    required this.addToMaintenance,
  });

  final num amount;
  final int? adjustmentMonth;
  final int? adjustmentYear;
  final bool addToMaintenance;

  factory AdjustmentDetails.fromJson(Map<String, dynamic> json) {
    return AdjustmentDetails(
      amount: (json['amount'] ?? 0) as num,
      adjustmentMonth: json['adjustmentMonth'] as int?,
      adjustmentYear: json['adjustmentYear'] as int?,
      addToMaintenance: (json['addToMaintenance'] ?? false) as bool,
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
    this.refundDetails,
    this.adjustmentDetails,
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
  final RefundDetails? refundDetails;
  final AdjustmentDetails? adjustmentDetails;

  factory MaintenanceIssue.fromJson(Map<String, dynamic> json) {
    final refundJson = json['refundDetails'] as Map<String, dynamic>?;
    final adjJson = json['adjustmentDetails'] as Map<String, dynamic>?;
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
      refundDetails:
          refundJson != null ? RefundDetails.fromJson(refundJson) : null,
      adjustmentDetails:
          adjJson != null ? AdjustmentDetails.fromJson(adjJson) : null,
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
