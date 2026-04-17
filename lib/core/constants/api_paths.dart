class ApiPaths {
  ApiPaths._();

  static const String tenantMobilePrefix = '/tenant-mobile';

  static const String login = '/login/tenant-mobile';
  static const String changePassword = '$tenantMobilePrefix/change-password';
  static const String dashboard = '$tenantMobilePrefix/dashboard';
  static const String history = '$tenantMobilePrefix/history';
  static const String notifications = '$tenantMobilePrefix/notifications';
  static const String documents = '$tenantMobilePrefix/documents';
  static const String profile = '$tenantMobilePrefix/profile';
  static const String currentAppVersion =
      '$tenantMobilePrefix/app-version/current';
}
