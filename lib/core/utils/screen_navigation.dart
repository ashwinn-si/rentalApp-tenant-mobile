const _screenRoutes = {
  'DASHBOARD': '/dashboard',
  'HISTORY': '/history',
  'DOCUMENTS': '/documents',
  'NOTIFICATIONS': '/notifications',
  'PROFILE': '/profile',
  'PAYMENT_PAGE': '/payment-page',
};

const _screenOrder = [
  'DASHBOARD',
  'HISTORY',
  'DOCUMENTS',
  'NOTIFICATIONS',
  'PROFILE',
  'PAYMENT_PAGE',
];

String getFirstEnabledScreenRoute(List<String> enabledScreens) {
  if (enabledScreens.isEmpty) {
    return _screenRoutes['DASHBOARD']!;
  }

  for (final screenKey in _screenOrder) {
    if (enabledScreens.contains(screenKey)) {
      return _screenRoutes[screenKey]!;
    }
  }

  return _screenRoutes['DASHBOARD']!;
}
