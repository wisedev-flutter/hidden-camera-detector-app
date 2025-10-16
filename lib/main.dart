import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/config/paywall_mode.dart';
import 'src/data/datasources/revenuecat_data_source.dart';
import 'src/data/repositories/revenuecat_subscription_repository.dart';
import 'src/domain/usecases/get_subscription_status_use_case.dart';
import 'src/domain/usecases/purchase_subscription_use_case.dart';
import 'src/domain/usecases/restore_purchases_use_case.dart';
import 'src/presentation/app/app.dart';
import 'src/presentation/onboarding/onboarding_storage.dart';
import 'src/presentation/subscription/subscription_controller.dart';

const _revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: '',
);

const _premiumEntitlementId = String.fromEnvironment(
  'REVENUECAT_ENTITLEMENT_ID',
  defaultValue: 'premium',
);

const _paywallModeValue = String.fromEnvironment(
  'PAYWALL_MODE',
  defaultValue: 'revenuecat',
);

const _appModeValue = String.fromEnvironment(
  'APP_MODE',
  defaultValue: 'mock',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appMode = _parseAppMode(_appModeValue);
  AppConfig.init(appMode);

  final onboardingCompleted = await const OnboardingStorage().isCompleted();
  final paywallMode = PaywallModeX.fromEnvironment(_paywallModeValue);

  final subscriptionController = AppConfig.instance.isMock
      ? SubscriptionController.mock()
      : _buildRealSubscriptionController();

  if (!AppConfig.instance.isMock) {
    await subscriptionController.initialize();
  }

  runApp(
    HiddenCameraDetectorApp(
      onboardingCompleted: onboardingCompleted,
      subscriptionController: subscriptionController,
      paywallMode: paywallMode,
    ),
  );
}

SubscriptionController _buildRealSubscriptionController() {
  final revenueCatDataSource = RevenueCatDataSource(apiKey: _revenueCatApiKey);

  final subscriptionRepository = RevenueCatSubscriptionRepository(
    dataSource: revenueCatDataSource,
    entitlementId: _premiumEntitlementId,
  );

  return SubscriptionController(
    dataSource: revenueCatDataSource,
    entitlementId: _premiumEntitlementId,
    getSubscriptionStatusUseCase: GetSubscriptionStatusUseCase(
      subscriptionRepository,
    ),
    purchaseSubscriptionUseCase: PurchaseSubscriptionUseCase(
      subscriptionRepository,
    ),
    restorePurchasesUseCase: RestorePurchasesUseCase(subscriptionRepository),
  );
}

AppMode _parseAppMode(String value) {
  switch (value.toLowerCase()) {
    case 'real':
      return AppMode.real;
    case 'mock':
    default:
      return AppMode.mock;
  }
}
