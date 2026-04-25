class PaymentProof {
  final String id;
  final String status;
  final String rentRecordId;
  final String paidToName;
  final double totalAmount;
  final List<PaymentMethod> paymentMethods;
  final List<ProofImage> proofImages;
  final String? rejectionReason;
  final DateTime? submittedAt;

  PaymentProof({
    required this.id,
    required this.status,
    required this.rentRecordId,
    required this.paidToName,
    required this.totalAmount,
    required this.paymentMethods,
    List<ProofImage>? proofImages,
    this.rejectionReason,
    this.submittedAt,
  }) : proofImages = proofImages ?? [];

  factory PaymentProof.fromJson(Map<String, dynamic> json) {
    return PaymentProof(
      id: json['_id'] ?? json['id'] ?? '',
      status: json['paymentProofStatus'] ?? json['status'] ?? 'pending',
      rentRecordId: json['rentRecordId'] ?? '',
      paidToName: json['paidToName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethods: (json['paymentMethods'] as List?)
              ?.map((m) => PaymentMethod.fromJson(m))
              .toList() ??
          [],
      proofImages: (json['proofImages'] as List?)
              ?.map((img) => ProofImage.fromJson(img))
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

class ProofImage {
  final String s3Key;
  final String? url; // Pre-signed URL from backend
  final DateTime? uploadedAt;

  ProofImage({required this.s3Key, this.url, this.uploadedAt});

  factory ProofImage.fromJson(Map<String, dynamic> json) {
    return ProofImage(
      s3Key: json['s3Key'] ?? '',
      url: json['url'],
      uploadedAt: json['uploadedAt'] != null ? DateTime.parse(json['uploadedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's3Key': s3Key,
      if (url != null) 'url': url,
      if (uploadedAt != null) 'uploadedAt': uploadedAt!.toIso8601String(),
    };
  }
}
