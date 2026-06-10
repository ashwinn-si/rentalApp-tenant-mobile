class BugReportImage {
  final String name;
  final String s3Key;
  final String? url;

  BugReportImage({
    required this.name,
    required this.s3Key,
    this.url,
  });

  factory BugReportImage.fromJson(Map<String, dynamic> json) {
    return BugReportImage(
      name: json['name'] as String? ?? '',
      s3Key: json['s3Key'] as String? ?? '',
      url: json['url'] as String?,
    );
  }
}

class BugReport {
  final String id;
  final String bugId;
  final String title;
  final String description;
  final BugType type;
  final BugStatus status;
  final List<BugReportImage> images;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BugReport({
    required this.id,
    required this.bugId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.images,
    this.resolutionNotes,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BugReport.fromJson(Map<String, dynamic> json) {
    return BugReport(
      id: json['_id'] as String? ?? '',
      bugId: json['bugId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _parseBugType(json['type'] as String?),
      status: _parseBugStatus(json['status'] as String?),
      images: ((json['images'] as List<dynamic>?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(BugReportImage.fromJson)
          .toList(),
      resolutionNotes: json['resolutionNotes'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  static BugType _parseBugType(String? type) {
    switch (type) {
      case 'ui_bug':
        return BugType.uiBug;
      case 'placement_bug':
        return BugType.placementBug;
      case 'performance':
        return BugType.performance;
      default:
        return BugType.other;
    }
  }

  static BugStatus _parseBugStatus(String? status) {
    switch (status) {
      case 'open':
        return BugStatus.open;
      case 'in_progress':
        return BugStatus.inProgress;
      case 'resolved':
        return BugStatus.resolved;
      case 'closed':
        return BugStatus.closed;
      default:
        return BugStatus.open;
    }
  }
}

enum BugType { uiBug, placementBug, performance, other }

enum BugStatus { open, inProgress, resolved, closed }

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class BugReportsResponseDto {
  final List<BugReport> items;
  final PaginationInfo pagination;

  BugReportsResponseDto({required this.items, required this.pagination});

  factory BugReportsResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BugReportsResponseDto(
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => BugReport.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: data['pagination'] != null
          ? PaginationInfo.fromJson(data['pagination'] as Map<String, dynamic>)
          : PaginationInfo(page: 1, limit: 10, total: 0, totalPages: 0),
    );
  }
}

extension BugTypeLabel on BugType {
  String get label {
    switch (this) {
      case BugType.uiBug:
        return 'UI Bug';
      case BugType.placementBug:
        return 'Placement Bug';
      case BugType.performance:
        return 'Performance';
      case BugType.other:
        return 'Other';
    }
  }

  String get apiValue {
    switch (this) {
      case BugType.uiBug:
        return 'ui_bug';
      case BugType.placementBug:
        return 'placement_bug';
      case BugType.performance:
        return 'performance';
      case BugType.other:
        return 'other';
    }
  }
}

extension BugStatusLabel on BugStatus {
  String get label {
    switch (this) {
      case BugStatus.open:
        return 'Open';
      case BugStatus.inProgress:
        return 'In Progress';
      case BugStatus.resolved:
        return 'Resolved';
      case BugStatus.closed:
        return 'Closed';
    }
  }
}
