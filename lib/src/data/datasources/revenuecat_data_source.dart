import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Lightweight wrapper around the RevenueCat Flutter SDK that centralises
/// configuration and access to [CustomerInfo] updates.
class RevenueCatDataSource {
  RevenueCatDataSource({
    required String apiKey,
    ConfigurePurchases configure = Purchases.configure,
    GetCustomerInfo getCustomerInfo = Purchases.getCustomerInfo,
    RestorePurchases restorePurchases = Purchases.restorePurchases,
    AddCustomerInfoUpdateListener addCustomerInfoUpdateListener =
        Purchases.addCustomerInfoUpdateListener,
    RemoveCustomerInfoUpdateListener removeCustomerInfoUpdateListener =
        Purchases.removeCustomerInfoUpdateListener,
    SetLogLevel setLogLevel = Purchases.setLogLevel,
  })  : _apiKey = apiKey,
        _configure = configure,
        _getCustomerInfo = getCustomerInfo,
        _restorePurchases = restorePurchases,
        _addCustomerInfoUpdateListener = addCustomerInfoUpdateListener,
        _removeCustomerInfoUpdateListener = removeCustomerInfoUpdateListener,
        _setLogLevel = setLogLevel;

  final String _apiKey;
  final ConfigurePurchases _configure;
  final GetCustomerInfo _getCustomerInfo;
  final RestorePurchases _restorePurchases;
  final AddCustomerInfoUpdateListener _addCustomerInfoUpdateListener;
  final RemoveCustomerInfoUpdateListener _removeCustomerInfoUpdateListener;
  final SetLogLevel _setLogLevel;

  bool _configured = false;

  late final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();
  bool _listenerAttached = false;

  Stream<CustomerInfo> get customerInfoStream =>
      _customerInfoController.stream;

  bool get isConfigured => _configured;

  Future<bool> configure() async {
    if (_configured) {
      return true;
    }

    if (_apiKey.isEmpty) {
      return false;
    }

    if (kDebugMode) {
      await _setLogLevel(LogLevel.debug);
    }

    final configuration = PurchasesConfiguration(_apiKey);

    await _configure(configuration);
    _attachCustomerInfoListener();
    _configured = true;
    return true;
  }

  Future<CustomerInfo> fetchCustomerInfo() {
    return _getCustomerInfo();
  }

  Future<CustomerInfo> restore() {
    return _restorePurchases();
  }

  void dispose() {
    if (_listenerAttached) {
      _removeCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
      _listenerAttached = false;
    }
    _customerInfoController.close();
  }

  void _attachCustomerInfoListener() {
    if (_listenerAttached) {
      return;
    }
    _addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
    _listenerAttached = true;
  }

  void _handleCustomerInfoUpdate(CustomerInfo info) {
    if (_customerInfoController.isClosed) {
      return;
    }
    _customerInfoController.add(info);
  }
}

typedef ConfigurePurchases = Future<void> Function(
  PurchasesConfiguration configuration,
);
typedef GetCustomerInfo = Future<CustomerInfo> Function();
typedef RestorePurchases = Future<CustomerInfo> Function();
typedef SetLogLevel = Future<void> Function(LogLevel level);
typedef AddCustomerInfoUpdateListener = void Function(
  CustomerInfoUpdateListener listener,
);
typedef RemoveCustomerInfoUpdateListener = void Function(
  CustomerInfoUpdateListener listener,
);
