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

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class PaymentProofsResponseDto {
  final List<PaymentProof> items;
  final PaginationInfo pagination;

  PaymentProofsResponseDto({required this.items, required this.pagination});

  factory PaymentProofsResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PaymentProofsResponseDto(
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => PaymentProof.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: data['pagination'] != null
          ? PaginationInfo.fromJson(data['pagination'] as Map<String, dynamic>)
          : PaginationInfo(page: 1, limit: 10, total: 0, totalPages: 0),
    );
  }
}
