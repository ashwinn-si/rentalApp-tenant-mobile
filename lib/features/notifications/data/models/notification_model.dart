class TenantNotification {
  const TenantNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.targetType,
    required this.expiresAt,
    required this.isExpired,
  });

  final String id;
  final String title;
  final String message;
  final String targetType;
  final String expiresAt;
  final bool isExpired;

  factory TenantNotification.fromJson(Map<String, dynamic> json) {
    final expiry = (json['expiresAt'] ??
            json['endDate'] ??
            DateTime.now().toIso8601String())
        .toString();
    final expiryDate = DateTime.tryParse(expiry);

    return TenantNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? '').toString(),
      targetType: (json['targetType'] ?? 'tenant').toString(),
      expiresAt: expiry,
      isExpired: json['isExpired'] == true ||
          (expiryDate != null && expiryDate.isBefore(DateTime.now())),
    );
  }
}
