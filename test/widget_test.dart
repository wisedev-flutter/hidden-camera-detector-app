// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hidden_camera_detector/core/config/paywall_mode.dart';
import 'package:hidden_camera_detector/src/data/datasources/revenuecat_data_source.dart';
import 'package:hidden_camera_detector/src/data/repositories/revenuecat_subscription_repository.dart';
import 'package:hidden_camera_detector/src/domain/usecases/get_subscription_status_use_case.dart';
import 'package:hidden_camera_detector/src/domain/usecases/purchase_subscription_use_case.dart';
import 'package:hidden_camera_detector/src/domain/usecases/restore_purchases_use_case.dart';
import 'package:hidden_camera_detector/src/presentation/app/app.dart';
import 'package:hidden_camera_detector/src/presentation/subscription/subscription_controller.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

CustomerInfo _createEmptyCustomerInfo() {
  return CustomerInfo.fromJson({
    'entitlements': {
      'all': <String, dynamic>{},
      'active': <String, dynamic>{},
      'verification': 'NOT_REQUESTED',
    },
    'allPurchaseDates': <String, dynamic>{},
    'activeSubscriptions': <dynamic>[],
    'allPurchasedProductIdentifiers': <dynamic>[],
    'nonSubscriptionTransactions': <dynamic>[],
    'firstSeen': '2024-01-01T00:00:00Z',
    'originalAppUserId': 'test-user',
    'allExpirationDates': <String, dynamic>{},
    'requestDate': '2024-01-01T00:00:00Z',
    'latestExpirationDate': null,
    'originalPurchaseDate': null,
    'originalApplicationVersion': null,
    'managementURL': null,
  });
}

void main() {
  testWidgets('Onboarding headline is shown when not completed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final customerInfo = _createEmptyCustomerInfo();

    final dataSource = RevenueCatDataSource(
      apiKey: 'test',
      configure: (_) async {},
      getCustomerInfo: () async => customerInfo,
      restorePurchases: () async => customerInfo,
      addCustomerInfoUpdateListener: (_) {},
      removeCustomerInfoUpdateListener: (_) {},
      setLogLevel: (_) async {},
    );

    final repository = RevenueCatSubscriptionRepository(
      dataSource: dataSource,
      entitlementId: 'premium',
    );

    final controller = SubscriptionController(
      dataSource: dataSource,
      entitlementId: 'premium',
      getSubscriptionStatusUseCase: GetSubscriptionStatusUseCase(repository),
      purchaseSubscriptionUseCase: PurchaseSubscriptionUseCase(repository),
      restorePurchasesUseCase: RestorePurchasesUseCase(repository),
    );

    await controller.initialize();

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(
      HiddenCameraDetectorApp(
        onboardingCompleted: false,
        subscriptionController: controller,
        paywallMode: PaywallMode.revenuecat,
      ),
    );

    await tester.pump();

    expect(find.text('Protect your privacy'), findsOneWidget);
  });
}
