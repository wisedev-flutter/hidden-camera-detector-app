import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, bool>> getSubscriptionStatus();
  Future<Either<Failure, bool>> purchaseSubscription();
  Future<Either<Failure, bool>> restorePurchases();
}
