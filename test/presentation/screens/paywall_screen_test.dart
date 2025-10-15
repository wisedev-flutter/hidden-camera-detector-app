import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_camera_detector/core/config/paywall_mode.dart';
import 'package:hidden_camera_detector/src/data/datasources/revenuecat_data_source.dart';
import 'package:hidden_camera_detector/src/data/repositories/revenuecat_subscription_repository.dart';
import 'package:hidden_camera_detector/src/domain/usecases/get_subscription_status_use_case.dart';
import 'package:hidden_camera_detector/src/domain/usecases/purchase_subscription_use_case.dart';
import 'package:hidden_camera_detector/src/domain/usecases/restore_purchases_use_case.dart';
import 'package:hidden_camera_detector/src/presentation/screens/paywall_screen.dart';
import 'package:hidden_camera_detector/src/presentation/subscription/subscription_controller.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

CustomerInfo _emptyCustomerInfo() {
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
  group('PaywallScreen', () {
    late SubscriptionController controller;

    setUp(() async {
      final customerInfo = _emptyCustomerInfo();
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

      controller = SubscriptionController(
        dataSource: dataSource,
        entitlementId: 'premium',
        getSubscriptionStatusUseCase: GetSubscriptionStatusUseCase(repository),
        purchaseSubscriptionUseCase: PurchaseSubscriptionUseCase(repository),
        restorePurchasesUseCase: RestorePurchasesUseCase(repository),
      );
      await controller.initialize();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('shows custom paywall options in custom mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SubscriptionControllerProvider(
            controller: controller,
            child: const PaywallScreen(paywallMode: PaywallMode.custom),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final weeklyFinder = find.byKey(const ValueKey('mock-plan-weekly'));
      await tester.scrollUntilVisible(weeklyFinder, 300);

      expect(weeklyFinder, findsOneWidget);
      expect(find.byKey(const ValueKey('mock-plan-monthly')), findsOneWidget);
      expect(find.text('Subscribe'), findsNWidgets(2));
    });
  });
}
