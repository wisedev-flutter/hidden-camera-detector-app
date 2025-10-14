enum AppRoute {
  onboarding('/onboarding'),
  dashboard('/dashboard'),
  scanWifi('/scan/wifi'),
  scanBluetooth('/scan/bluetooth'),
  scanIr('/scan/ir'),
  results('/results'),
  settings('/settings'),
  paywall('/paywall');

  const AppRoute(this.path);

  final String path;
}
