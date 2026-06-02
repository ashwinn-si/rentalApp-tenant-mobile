class MaintenanceBreakdownItem {
  final String name;
  final double totalCost;
  final double yourShare;
  final String? issueId;
  final String? issueType;
  final String? issueDate;

  MaintenanceBreakdownItem({
    required this.name,
    required this.totalCost,
    required this.yourShare,
    this.issueId,
    this.issueType,
    this.issueDate,
  });

  factory MaintenanceBreakdownItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceBreakdownItem(
      name: json['name'] ?? '',
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      yourShare: (json['yourShare'] ?? 0).toDouble(),
      issueId: json['issueId'],
      issueType: json['issueType'],
      issueDate: json['issueDate'],
    );
  }
}

class RentRecord {
  final String id;
  final int rentMonth;
  final int rentYear;
  final double baseRent;
  final double electricityBill;
  final double maintenanceShare;
  final List<MaintenanceBreakdownItem> maintenanceBreakdown;
  final double previousDues;
  final double totalDue;
  final double paidAmount;
  final String status;
  final String? paymentProofStatus;
  final String? paymentProofId;

  RentRecord({
    required this.id,
    required this.rentMonth,
    required this.rentYear,
    required this.baseRent,
    required this.electricityBill,
    required this.maintenanceShare,
    required this.totalDue,
    required this.paidAmount,
    required this.status,
    this.maintenanceBreakdown = const [],
    this.previousDues = 0,
    this.paymentProofStatus,
    this.paymentProofId,
  });

  factory RentRecord.fromJson(Map<String, dynamic> json) {
    final breakdownList = (json['maintenanceBreakdown'] as List?)
            ?.map((item) => MaintenanceBreakdownItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final baseRent = (json['baseRent'] ?? 0).toDouble();
    final electricityBill = (json['electricityBill'] ?? 0).toDouble();
    final maintenanceShare = (json['maintenanceShare'] ?? 0).toDouble();
    final totalDue = (json['totalDue'] ?? 0).toDouble();

    return RentRecord(
      id: json['_id'] ?? '',
      rentMonth: json['rentMonth'] ?? 0,
      rentYear: json['rentYear'] ?? 0,
      baseRent: baseRent,
      electricityBill: electricityBill,
      maintenanceShare: maintenanceShare,
      totalDue: totalDue,
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'unpaid',
      maintenanceBreakdown: breakdownList,
      previousDues: (json['previousDues'] ?? 0).toDouble(),
      paymentProofStatus: json['paymentProofStatus'],
      paymentProofId: json['paymentProofId'],
    );
  }
}
