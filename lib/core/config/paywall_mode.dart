enum PaywallMode { revenuecat, custom }

extension PaywallModeX on PaywallMode {
  static PaywallMode fromEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'custom':
      case 'mock':
        return PaywallMode.custom;
      case 'revenuecat':
      default:
        return PaywallMode.revenuecat;
    }
  }

  bool get isCustom => this == PaywallMode.custom;
  bool get isRevenueCat => this == PaywallMode.revenuecat;
}
