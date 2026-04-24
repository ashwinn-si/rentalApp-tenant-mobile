class ApiPaths {
  ApiPaths._();

  static const String tenantMobilePrefix = '/tenant-mobile';
  static const String tenantPrefix = '/tenant';

  static const String login = '/auth/tenant-mobile';
  static const String changePassword = '$tenantMobilePrefix/change-password';
  static const String fcmToken = '$tenantMobilePrefix/fcm-token';
  static const String dashboard = '$tenantMobilePrefix/dashboard';
  static const String history = '$tenantMobilePrefix/history';
  static const String notifications = '$tenantMobilePrefix/notifications';
  static const String documents = '$tenantMobilePrefix/documents';
  static const String profile = '$tenantMobilePrefix/profile';
  static const String currentAppVersion =
      '$tenantMobilePrefix/app-version/current';
  static const String maintenanceIssues =
      '$tenantMobilePrefix/maintenance-issues';
  static const String rentByMonthYear = '$tenantPrefix/rent';
  static const String paymentProofs = '$tenantPrefix/payment-proofs';
  static const String s3UploadUrls = '$tenantPrefix/s3-upload-urls';
}
