class PaymentProof {
  final String id;
  final String status;
  final String rentRecordId;
  final String paidToName;
  final double totalAmount;
  final List<PaymentMethod> paymentMethods;
  final String? rejectionReason;
  final DateTime? submittedAt;

  PaymentProof({
    required this.id,
    required this.status,
    required this.rentRecordId,
    required this.paidToName,
    required this.totalAmount,
    required this.paymentMethods,
    this.rejectionReason,
    this.submittedAt,
  });

  factory PaymentProof.fromJson(Map<String, dynamic> json) {
    return PaymentProof(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      rentRecordId: json['rentRecordId'] ?? '',
      paidToName: json['paidToName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethods: (json['paymentMethods'] as List?)
              ?.map((m) => PaymentMethod.fromJson(m))
              .toList() ??
          [],
      rejectionReason: json['rejectionReason'],
      submittedAt:
          json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
    );
  }
}

class PaymentMethod {
  final String method;
  final double amount;

  PaymentMethod({required this.method, required this.amount});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      method: json['method'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'amount': amount,
    };
  }
}
