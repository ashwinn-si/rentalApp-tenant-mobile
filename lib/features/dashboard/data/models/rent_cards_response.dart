class RentCard {
  const RentCard({
    required this.month,
    required this.year,
    required this.monthLabel,
    required this.isLast3Months,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenanceShare,
    required this.extra,
    required this.totalDue,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
  });

  final int month;
  final int year;
  final String monthLabel;
  final bool isLast3Months;
  final num baseRent;
  final num utilityBill;
  final num maintenanceShare;
  final num extra;
  final num totalDue;
  final num paidAmount;
  final num pendingAmount;
  final String status;

  factory RentCard.fromJson(Map<String, dynamic> json) {
    return RentCard(
      month: (json['month'] as num? ?? 0).toInt(),
      year: (json['year'] as num? ?? 0).toInt(),
      monthLabel: (json['monthLabel'] ?? '').toString(),
      isLast3Months: (json['isLast3Months'] as bool?) ?? false,
      baseRent: (json['baseRent'] as num?) ?? 0,
      utilityBill: (json['utilityBill'] as num?) ?? 0,
      maintenanceShare: (json['maintenanceShare'] as num?) ?? 0,
      extra: (json['extra'] as num?) ?? 0,
      totalDue: (json['totalDue'] as num?) ?? 0,
      paidAmount: (json['paidAmount'] as num?) ?? 0,
      pendingAmount: (json['pendingAmount'] as num?) ?? 0,
      status: (json['status'] ?? '').toString(),
    );
  }
}

class RentCardsResponse {
  const RentCardsResponse({
    required this.cards,
    this.flatLabel,
    this.flatNumber,
    this.apartmentName,
  });

  final List<RentCard> cards;
  final String? flatLabel;
  final String? flatNumber;
  final String? apartmentName;

  factory RentCardsResponse.fromJson(Map<String, dynamic> json) {
    final rawCards = (json['cards'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return RentCardsResponse(
      cards: rawCards.map(RentCard.fromJson).toList(),
      flatLabel: (json['flatLabel'] ?? '').toString().isEmpty
          ? null
          : (json['flatLabel'] ?? '').toString(),
      flatNumber: (json['flatNumber'] ?? '').toString().isEmpty
          ? null
          : (json['flatNumber'] ?? '').toString(),
      apartmentName: (json['apartmentName'] ?? '').toString().isEmpty
          ? null
          : (json['apartmentName'] ?? '').toString(),
    );
  }

  factory RentCardsResponse.empty() {
    return const RentCardsResponse(cards: <RentCard>[]);
  }
}
