class FlatDto {
  const FlatDto({
    required this.id,
    required this.label,
    required this.apartmentName,
    required this.flatNumber,
  });

  final String id;
  final String label;
  final String apartmentName;
  final String flatNumber;

  factory FlatDto.fromJson(Map<String, dynamic> json) {
    return FlatDto(
      id: (json['id'] ?? json['flatId'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      apartmentName: (json['apartmentName'] ?? '').toString(),
      flatNumber: (json['flatNumber'] ?? '').toString(),
    );
  }
}

class DashboardResponse {
  const DashboardResponse({
    required this.availableFlats,
    required this.totalOutstanding,
  });

  final List<FlatDto> availableFlats;
  final num totalOutstanding;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final rawFlats = (json['availableFlats'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    final analytics = (json['analytics'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    return DashboardResponse(
      availableFlats: rawFlats.map(FlatDto.fromJson).toList(),
      totalOutstanding: (json['totalOutstanding'] ??
          analytics['totalOutstanding'] ??
          0) as num,
    );
  }

  factory DashboardResponse.empty() {
    return const DashboardResponse(
        availableFlats: <FlatDto>[], totalOutstanding: 0);
  }
}
