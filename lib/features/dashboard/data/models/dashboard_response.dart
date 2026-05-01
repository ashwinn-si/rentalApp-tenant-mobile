class FlatDto {
  const FlatDto({
    required this.id,
    required this.label,
    required this.apartmentName,
    required this.flatNumber,
    required this.apartmentId,
  });

  final String id;
  final String label;
  final String apartmentName;
  final String flatNumber;
  final String apartmentId;

  factory FlatDto.fromJson(Map<String, dynamic> json) {
    return FlatDto(
      id: (json['id'] ?? json['flatId'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      apartmentName: (json['apartmentName'] ?? '').toString(),
      flatNumber: (json['flatNumber'] ?? '').toString(),
      apartmentId: (json['apartmentId'] ?? '').toString(),
    );
  }
}

class RecentRentDto {
  const RecentRentDto({
    required this.month,
    required this.year,
    required this.monthLabel,
    required this.isCurrentMonth,
    required this.baseRent,
    required this.utilityBill,
    required this.maintenanceShare,
    required this.totalDue,
    required this.paidAmount,
  });

  final int month;
  final int year;
  final String monthLabel;
  final bool isCurrentMonth;
  final num baseRent;
  final num utilityBill;
  final num maintenanceShare;
  final num totalDue;
  final num paidAmount;

  factory RecentRentDto.fromJson(Map<String, dynamic> json) {
    return RecentRentDto(
      month: (json['month'] as num? ?? 0).toInt(),
      year: (json['year'] as num? ?? 0).toInt(),
      monthLabel: (json['monthLabel'] ?? '').toString(),
      isCurrentMonth: (json['isCurrentMonth'] as bool?) ?? false,
      baseRent: (json['baseRent'] as num?) ?? 0,
      utilityBill: (json['utilityBill'] as num?) ?? 0,
      maintenanceShare: (json['maintenanceShare'] as num?) ?? 0,
      totalDue: (json['totalDue'] as num?) ?? 0,
      paidAmount: (json['paidAmount'] as num?) ?? 0,
    );
  }
}

class DashboardResponse {
  const DashboardResponse({
    required this.availableFlats,
    required this.totalOutstanding,
    required this.recentRents,
  });

  final List<FlatDto> availableFlats;
  final num totalOutstanding;
  final List<RecentRentDto> recentRents;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final rawFlats = (json['availableFlats'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    final analytics = (json['analytics'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final rawRecentRents =
        (json['recentRents'] as List<dynamic>? ?? <dynamic>[])
            .cast<Map<String, dynamic>>();
    return DashboardResponse(
      availableFlats: rawFlats.map(FlatDto.fromJson).toList(),
      totalOutstanding: (json['totalOutstanding'] ??
          analytics['totalOutstanding'] ??
          0) as num,
      recentRents: rawRecentRents.map(RecentRentDto.fromJson).toList(),
    );
  }

  factory DashboardResponse.empty() {
    return const DashboardResponse(
        availableFlats: <FlatDto>[], totalOutstanding: 0, recentRents: []);
  }
}
