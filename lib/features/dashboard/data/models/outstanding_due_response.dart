class OutstandingDueMonth {
  const OutstandingDueMonth({
    required this.name,
    required this.amount,
  });

  final String name;
  final num amount;

  factory OutstandingDueMonth.fromJson(Map<String, dynamic> json) {
    return OutstandingDueMonth(
      name: (json['name'] ?? '').toString(),
      amount: (json['amount'] ?? 0) as num,
    );
  }
}

class OutstandingDueResponse {
  const OutstandingDueResponse({
    required this.outstandingDue,
    required this.months,
  });

  final num outstandingDue;
  final List<OutstandingDueMonth> months;

  factory OutstandingDueResponse.fromJson(Map<String, dynamic> json) {
    final rawMonths = (json['months'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(OutstandingDueMonth.fromJson)
        .toList();

    return OutstandingDueResponse(
      outstandingDue: (json['outstandingDue'] ?? 0) as num,
      months: rawMonths,
    );
  }

  factory OutstandingDueResponse.empty() {
    return const OutstandingDueResponse(
      outstandingDue: 0,
      months: [],
    );
  }
}
