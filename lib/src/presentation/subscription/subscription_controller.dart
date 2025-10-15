import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../core/logging/app_logger.dart';
import '../../data/datasources/revenuecat_data_source.dart';
import '../../domain/usecases/get_subscription_status_use_case.dart';
import '../../domain/usecases/purchase_subscription_use_case.dart';
import '../../domain/usecases/restore_purchases_use_case.dart';

class SubscriptionController with ChangeNotifier {
  SubscriptionController({
    required RevenueCatDataSource dataSource,
    required String entitlementId,
    required GetSubscriptionStatusUseCase getSubscriptionStatusUseCase,
    required PurchaseSubscriptionUseCase purchaseSubscriptionUseCase,
    required RestorePurchasesUseCase restorePurchasesUseCase,
  }) : _dataSource = dataSource,
       _entitlementId = entitlementId,
       _getSubscriptionStatusUseCase = getSubscriptionStatusUseCase,
       _purchaseSubscriptionUseCase = purchaseSubscriptionUseCase,
       _restorePurchasesUseCase = restorePurchasesUseCase {
    _isPremiumNotifier.addListener(notifyListeners);
  }

  final RevenueCatDataSource _dataSource;
  final String _entitlementId;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final RestorePurchasesUseCase _restorePurchasesUseCase;

  final ValueNotifier<bool> _isPremiumNotifier = ValueNotifier<bool>(false);

  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  ValueListenable<bool> get premiumListenable => _isPremiumNotifier;

  bool get isPremium => _isPremiumNotifier.value;

  bool get isConfigured => _dataSource.isConfigured;

  Future<void> initialize() async {
    AppLogger.log.debug('Initialising subscription controller');
    final configured = await _dataSource.configure();
    if (!configured) {
      AppLogger.log.warn(
        'RevenueCat not configured. Premium features remain locked.',
      );
      return;
    }

    AppLogger.log.info('RevenueCat configured successfully');

    await _refreshStatus();

    _customerInfoSubscription ??= _dataSource.customerInfoStream.listen(
      _handleCustomerInfoUpdate,
    );
  }

  Future<void> _refreshStatus() async {
    if (!_dataSource.isConfigured) {
      _isPremiumNotifier.value = false;
      return;
    }
    final result = await _getSubscriptionStatusUseCase();
    result.fold(
      (_) => _isPremiumNotifier.value = false,
      (isPremium) => _isPremiumNotifier.value = isPremium,
    );
  }

  Future<bool> restorePurchases() async {
    if (!_dataSource.isConfigured) {
      AppLogger.log.warn(
        'Restore requested before RevenueCat configuration completed.',
      );
      return false;
    }
    final result = await _restorePurchasesUseCase();
    return result.fold((_) => false, (success) {
      _isPremiumNotifier.value = success;
      AppLogger.log.info(
        'Restore purchases completed.',
        data: {'isPremium': success},
      );
      return success;
    });
  }

  Future<void> handlePaywallResult(PaywallResult result) async {
    if (!_dataSource.isConfigured) {
      AppLogger.log.warn(
        'Paywall result ignored because RevenueCat is not configured.',
        data: {'result': result.name},
      );
      return;
    }
    if (result == PaywallResult.purchased || result == PaywallResult.restored) {
      final purchaseResult = await _purchaseSubscriptionUseCase();
      purchaseResult.fold(
        (_) => _isPremiumNotifier.value = false,
        (isPremium) => _isPremiumNotifier.value = isPremium,
      );
      AppLogger.log.info(
        'Paywall flow completed.',
        data: {'result': result.name, 'isPremium': _isPremiumNotifier.value},
      );
    }
  }

  void _handleCustomerInfoUpdate(CustomerInfo info) {
    final isActive = info.entitlements.active.containsKey(_entitlementId);
    if (_isPremiumNotifier.value != isActive) {
      _isPremiumNotifier.value = isActive;
    }
    AppLogger.log.debug(
      'Customer info updated.',
      data: {
        'activeEntitlements': info.entitlements.active.keys.toList(),
        'isPremium': isActive,
      },
    );
  }

  void reset() {
    _isPremiumNotifier.value = false;
    AppLogger.log.debug('Subscription controller reset.');
  }

  @override
  void dispose() {
    _customerInfoSubscription?.cancel();
    _isPremiumNotifier.removeListener(notifyListeners);
    _isPremiumNotifier.dispose();
    _dataSource.dispose();
    super.dispose();
  }
}

class SubscriptionControllerProvider
    extends InheritedNotifier<SubscriptionController> {
  const SubscriptionControllerProvider({
    super.key,
    required SubscriptionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SubscriptionController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<SubscriptionControllerProvider>();
    assert(
      provider != null,
      'SubscriptionControllerProvider.of() called with no provider in context.',
    );
    return provider!.notifier!;
  }
}
