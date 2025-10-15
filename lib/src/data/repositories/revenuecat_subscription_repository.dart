import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/exceptions/failure.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/revenuecat_data_source.dart';

class RevenueCatSubscriptionRepository implements SubscriptionRepository {
  RevenueCatSubscriptionRepository({
    required RevenueCatDataSource dataSource,
    required String entitlementId,
  })  : _dataSource = dataSource,
        _entitlementId = entitlementId;

  final RevenueCatDataSource _dataSource;
  final String _entitlementId;

  String get entitlementId => _entitlementId;

  @override
  Future<Either<Failure, bool>> getSubscriptionStatus() async {
    return _wrapCustomerInfoCall(_dataSource.fetchCustomerInfo);
  }

  @override
  Future<Either<Failure, bool>> purchaseSubscription() async {
    return _wrapCustomerInfoCall(_dataSource.fetchCustomerInfo);
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    return _wrapCustomerInfoCall(_dataSource.restore);
  }

  Either<Failure, bool> _mapCustomerInfo(CustomerInfo info) {
    final isActive = info.entitlements.active.containsKey(_entitlementId);
    return right(isActive);
  }

  Future<Either<Failure, bool>> _wrapCustomerInfoCall(
    Future<CustomerInfo> Function() action,
  ) async {
    try {
      final info = await action();
      return _mapCustomerInfo(info);
    } on PlatformException catch (error) {
      return left(Failure.subscription(message: error.message));
    } catch (error) {
      return left(
        Failure.unexpected(message: error.toString()),
      );
    }
  }
}
