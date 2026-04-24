class MaintenanceBreakdownItem {
  const MaintenanceBreakdownItem({
    required this.name,
    required this.amount,
    required this.type,
  });

  final String name;
  final num amount;
  final String type; // 'reimbursement', 'adjustment', or null

  factory MaintenanceBreakdownItem.fromJson(Map<String, dynamic> json) {
    final yourShare = (json['yourShare'] ?? 0) as num;
    final issueType = (json['issueType'] ?? 'adjustment').toString();
    final name = (json['name'] ?? '').toString();

    return MaintenanceBreakdownItem(
      name: name,
      amount: yourShare,
      type: issueType,
    );
  }
}

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
    this.maintenanceBreakdownItems = const <MaintenanceBreakdownItem>[],
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
  final List<MaintenanceBreakdownItem> maintenanceBreakdownItems;

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _formatMonthLabel(
      {dynamic month, dynamic year, dynamic rawLabel}) {
    int? monthValue;
    int? yearValue;

    if (month != null) {
      monthValue = month is int ? month : int.tryParse('$month');
    }
    if (year != null) {
      yearValue = year is int ? year : int.tryParse('$year');
    }

    if (monthValue != null &&
        yearValue != null &&
        monthValue >= 1 &&
        monthValue <= 12) {
      return '${_monthNames[monthValue - 1]} $yearValue';
    }

    final label = (rawLabel ?? '').toString().trim();
    final slashParts = label.split('/');
    if (slashParts.length == 2) {
      final parsedMonth = int.tryParse(slashParts[0].trim());
      final parsedYear = int.tryParse(slashParts[1].trim());
      if (parsedMonth != null &&
          parsedYear != null &&
          parsedMonth >= 1 &&
          parsedMonth <= 12) {
        return '${_monthNames[parsedMonth - 1]} $parsedYear';
      }
    }

    return label.isNotEmpty ? label : 'Unknown';
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['breakdown'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final month = json['month'];
    final year = json['year'];
    final monthLabel = _formatMonthLabel(
      month: month,
      year: year,
      rawLabel: json['monthLabel'],
    );

    // Parse maintenance breakdown items with proper signs
    final maintenanceBreakdown = (breakdown['maintenanceBreakdown'] as List<dynamic>?) ?? <dynamic>[];
    final breakdownItems = <MaintenanceBreakdownItem>[];
    num maintenanceTotal = (json['maintenance'] ?? breakdown['maintenanceShare'] ?? 0) as num;

    for (final item in maintenanceBreakdown) {
      if (item is Map<String, dynamic>) {
        final breakdownItem = MaintenanceBreakdownItem.fromJson(item);
        breakdownItems.add(breakdownItem);
        // Apply signs: reimbursement subtracts, adjustment adds
        if (breakdownItem.type == 'reimbursement') {
          maintenanceTotal -= breakdownItem.amount;
        } else {
          maintenanceTotal += breakdownItem.amount;
        }
      }
    }

    return HistoryItem(
      monthLabel: monthLabel,
      status: (json['status'] ?? 'pending').toString(),
      baseRent: (json['baseRent'] ?? breakdown['baseRent'] ?? 0) as num,
      utilityBill:
          (json['utilityBill'] ?? breakdown['utilityBill'] ?? 0) as num,
      maintenance: maintenanceTotal,
      previousDues:
          (json['previousDues'] ?? breakdown['previousDues'] ?? 0) as num,
      totalDue: (json['totalDue'] ?? breakdown['totalDue'] ?? 0) as num,
      paidAmount: (json['paidAmount'] ?? 0) as num,
      flatId: (json['flatId'] ?? '').toString(),
      maintenanceBreakdownItems: breakdownItems,
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
