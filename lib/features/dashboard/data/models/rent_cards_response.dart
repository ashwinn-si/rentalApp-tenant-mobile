class RentCard {
  const RentCard({
    required this.monthLabel,
    required this.status,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenance,
    required this.extra,
    required this.previousDues,
    required this.totalDue,
    required this.paidAmount,
    required this.flatId,
    required this.flatLabel,
    required this.flatNumber,
    required this.apartmentName,
    this.maintenanceBreakdown = const <MaintenanceItem>[],
  });

  final String monthLabel;
  final String status;
  final num baseRent;
  final num utilityBill;
  final num maintenance;
  final num extra;
  final num previousDues;
  final num totalDue;
  final num paidAmount;
  final String flatId;
  final String flatLabel;
  final String flatNumber;
  final String apartmentName;
  final List<MaintenanceItem> maintenanceBreakdown;

  factory RentCard.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = (json['maintenanceBreakdown'] as List<dynamic>?) ?? <dynamic>[];

    return RentCard(
      monthLabel: (json['monthLabel'] ?? '').toString(),
      status: (json['status'] ?? 'Pending').toString(),
      baseRent: (json['baseRent'] ?? 0) as num,
      utilityBill: (json['utilityBill'] ?? 0) as num,
      maintenance: (json['maintenance'] ?? 0) as num,
      extra: (json['extra'] ?? 0) as num,
      previousDues: (json['previousDues'] ?? 0) as num,
      totalDue: (json['totalDue'] ?? 0) as num,
      paidAmount: (json['paidAmount'] ?? 0) as num,
      flatId: (json['flatId'] ?? '').toString(),
      flatLabel: (json['flatLabel'] ?? '').toString(),
      flatNumber: (json['flatNumber'] ?? '').toString(),
      apartmentName: (json['apartmentName'] ?? '').toString(),
      maintenanceBreakdown: rawBreakdown
          .whereType<Map<String, dynamic>>()
          .map(MaintenanceItem.fromJson)
          .toList(),
    );
  }
}

class MaintenanceItem {
  const MaintenanceItem({
    required this.name,
    required this.yourShare,
    required this.totalCost,
    required this.type,
    this.id,
    this.issueId,
  });

  final String name;
  final num yourShare;
  final num totalCost;
  final String type;
  final String? id;
  final String? issueId;

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      name: (json['name'] ?? '').toString(),
      yourShare: (json['yourShare'] ?? json['amount'] ?? 0) as num,
      totalCost: (json['totalCost'] ?? 0) as num,
      type: (json['type'] ?? json['issueType'] ?? 'adjustment').toString(),
      id: json['id']?.toString() ?? json['_id']?.toString(),
      issueId: json['issueId']?.toString(),
    );
  }
}

class RentCardsResponse {
  const RentCardsResponse({required this.items});

  final List<RentCard> items;

  factory RentCardsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return RentCardsResponse(
      items: rawItems.map(RentCard.fromJson).toList(),
    );
  }

  factory RentCardsResponse.empty() {
    return const RentCardsResponse(items: <RentCard>[]);
  }
}
