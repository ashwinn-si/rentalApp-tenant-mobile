class RentRecord {
  final String id;
  final int rentMonth;
  final int rentYear;
  final double baseRent;
  final double electricityBill;
  final double maintenanceShare;
  final double totalDue;
  final double paidAmount;
  final String status;

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
  });

  factory RentRecord.fromJson(Map<String, dynamic> json) {
    return RentRecord(
      id: json['_id'] ?? '',
      rentMonth: json['rentMonth'] ?? 0,
      rentYear: json['rentYear'] ?? 0,
      baseRent: (json['baseRent'] ?? 0).toDouble(),
      electricityBill: (json['electricityBill'] ?? 0).toDouble(),
      maintenanceShare: (json['maintenanceShare'] ?? 0).toDouble(),
      totalDue: (json['totalDue'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'unpaid',
    );
  }
}
