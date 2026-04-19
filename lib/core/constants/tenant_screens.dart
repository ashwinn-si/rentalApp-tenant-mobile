/// Screen keys for the tenant portal. ALL screens are optional —
/// super admin toggles per client via tenantEnabledScreens.
/// Add new screen keys here when creating a new tenant screen.
class TenantScreens {
  TenantScreens._();

  static const String dashboard = 'DASHBOARD';
  static const String history = 'HISTORY';
  static const String documents = 'DOCUMENTS';
  static const String notifications = 'NOTIFICATIONS';
  static const String profile = 'PROFILE';
  static const String paymentPage = 'PAYMENT_PAGE';
}
