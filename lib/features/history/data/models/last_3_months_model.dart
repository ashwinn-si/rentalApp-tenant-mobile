class Last3MonthsItem {
  final String monthLabel;
  final double baseRent;
  final double utility;
  final double maintenance;
  final double totalDue;
  final double paidAmount;
  final double pendingAmount;
  final String status;

  Last3MonthsItem({
    required this.monthLabel,
    required this.baseRent,
    required this.utility,
    required this.maintenance,
    required this.totalDue,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
  });

  factory Last3MonthsItem.fromJson(Map<String, dynamic> json) {
    return Last3MonthsItem(
      monthLabel: (json['monthLabel'] ?? '').toString(),
      baseRent: ((json['baseRent'] as num?) ?? 0).toDouble(),
      utility: ((json['utility'] as num?) ?? 0).toDouble(),
      maintenance: ((json['maintenance'] as num?) ?? 0).toDouble(),
      totalDue: ((json['totalDue'] as num?) ?? 0).toDouble(),
      paidAmount: ((json['paidAmount'] as num?) ?? 0).toDouble(),
      pendingAmount: ((json['pendingAmount'] as num?) ?? 0).toDouble(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class Last3MonthsComparison {
  final String flatLabel;
  final List<Last3MonthsItem> items;

  Last3MonthsComparison({
    required this.flatLabel,
    required this.items,
  });

  factory Last3MonthsComparison.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return Last3MonthsComparison(
      flatLabel: (json['flatLabel'] ?? '').toString(),
      items: rawItems.map(Last3MonthsItem.fromJson).toList(),
    );
  }
}
