class ApiPaths {
  ApiPaths._();

  static const String tenantMobilePrefix = '/tenant-mobile';
  static const String tenantPrefix = '/tenant';

  static const String login = '/auth/tenant-mobile';
  static const String changePassword = '$tenantMobilePrefix/auth/change-password';
  static const String fcmToken = '$tenantMobilePrefix/fcm-token';
  static const String activeRentMonth = '$tenantMobilePrefix/portal/active-month';
  static const String dashboard = '$tenantMobilePrefix/dashboard';
  static const String dashboardLast3Months = '$tenantMobilePrefix/dashboard/last-3-months';
  static const String history = '$tenantMobilePrefix/history';
  static const String notifications = '$tenantMobilePrefix/notifications';
  static const String documents = '$tenantMobilePrefix/documents';
  static const String profile = '$tenantMobilePrefix/profile';
  static const String currentAppVersion =
      '$tenantMobilePrefix/app-version/current';
  static const String maintenanceIssues =
      '$tenantMobilePrefix/maintenance-issues';
  static const String paymentProofs = '$tenantMobilePrefix/payment-proofs';
  static const String s3UploadUrls = '$tenantMobilePrefix/s3-upload-urls';
  static const String flatDetails = '$tenantMobilePrefix/flat-details';
  static const String bugReports = '$tenantMobilePrefix/bug-reports';
}
