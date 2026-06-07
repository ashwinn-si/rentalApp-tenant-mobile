import 'history_response.dart';

class HistoryCardItem {
  final String id;
  final int month;
  final int year;
  final String flatId;
  final String flatNumber;
  final String apartmentName;
  final String flatLabel;
  final String status;
  final double baseRent;
  final double utilityBill;
  final double maintenance;
  final double extra;
  final double totalDue;
  final double paidAmount;
  final List<MaintenanceBreakdownItem> maintenanceBreakdown;

  HistoryCardItem({
    required this.id,
    required this.month,
    required this.year,
    required this.flatId,
    required this.flatNumber,
    required this.apartmentName,
    required this.flatLabel,
    required this.status,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenance,
    required this.extra,
    required this.totalDue,
    required this.paidAmount,
    required this.maintenanceBreakdown,
  });

  factory HistoryCardItem.fromJson(Map<String, dynamic> json) {
    final rawBreakdown =
        (json['maintenanceBreakdown'] as List<dynamic>? ?? <dynamic>[])
            .cast<Map<String, dynamic>>();
    return HistoryCardItem(
      id: (json['id'] ?? '').toString(),
      month: (json['month'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num?)?.toInt() ?? 0,
      flatId: (json['flatId'] ?? '').toString(),
      flatNumber: (json['flatNumber'] ?? '').toString(),
      apartmentName: (json['apartmentName'] ?? '').toString(),
      flatLabel: (json['flatLabel'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      baseRent: ((json['baseRent'] as num?) ?? 0).toDouble(),
      utilityBill: ((json['utilityBill'] as num?) ?? 0).toDouble(),
      maintenance: ((json['maintenance'] as num?) ?? 0).toDouble(),
      extra: ((json['extra'] as num?) ?? 0).toDouble(),
      totalDue: ((json['totalDue'] as num?) ?? 0).toDouble(),
      paidAmount: ((json['paidAmount'] as num?) ?? 0).toDouble(),
      maintenanceBreakdown: rawBreakdown
          .map(MaintenanceBreakdownItem.fromJson)
          .toList(),
    );
  }
}

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
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 3,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class HistoryCardsResponse {
  final String? activeFlatId;
  final List<HistoryCardItem> items;
  final PaginationInfo pagination;

  HistoryCardsResponse({
    required this.activeFlatId,
    required this.items,
    required this.pagination,
  });

  factory HistoryCardsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return HistoryCardsResponse(
      activeFlatId: (json['activeFlatId'] as String?),
      items: rawItems.map(HistoryCardItem.fromJson).toList(),
      pagination: PaginationInfo.fromJson(
        (json['pagination'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
