class HistoryItem {
  const HistoryItem({
    required this.monthLabel,
    required this.status,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenance,
    required this.previousDues,
    required this.totalDue,
    required this.paidAmount,
    required this.flatId,
  });

  final String monthLabel;
  final String status;
  final num baseRent;
  final num utilityBill;
  final num maintenance;
  final num previousDues;
  final num totalDue;
  final num paidAmount;
  final String flatId;

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['breakdown'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final month = json['month'];
    final year = json['year'];
    final monthLabel = (json['monthLabel'] ??
            ((month != null && year != null) ? '$month/$year' : 'Unknown'))
        .toString();

    return HistoryItem(
      monthLabel: monthLabel,
      status: (json['status'] ?? 'pending').toString(),
      baseRent: (json['baseRent'] ?? breakdown['baseRent'] ?? 0) as num,
      utilityBill:
          (json['utilityBill'] ?? breakdown['utilityBill'] ?? 0) as num,
      maintenance:
          (json['maintenance'] ?? breakdown['maintenanceShare'] ?? 0) as num,
      previousDues:
          (json['previousDues'] ?? breakdown['previousDues'] ?? 0) as num,
      totalDue: (json['totalDue'] ?? breakdown['totalDue'] ?? 0) as num,
      paidAmount: (json['paidAmount'] ?? 0) as num,
      flatId: (json['flatId'] ?? '').toString(),
    );
  }
}

class HistoryResponse {
  const HistoryResponse(
      {required this.items, required this.page, required this.totalPages});

  final List<HistoryItem> items;
  final int page;
  final int totalPages;

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    final pagination = (json['pagination'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    final pageValue = json['page'] ?? pagination['page'] ?? 1;
    final totalPagesValue = json['totalPages'] ?? pagination['totalPages'] ?? 1;

    return HistoryResponse(
      items: rawItems.map(HistoryItem.fromJson).toList(),
      page: pageValue is int ? pageValue : int.tryParse('$pageValue') ?? 1,
      totalPages: totalPagesValue is int
          ? totalPagesValue
          : int.tryParse('$totalPagesValue') ?? 1,
    );
  }

  factory HistoryResponse.empty() {
    return const HistoryResponse(
        items: <HistoryItem>[], page: 1, totalPages: 1);
  }
}
