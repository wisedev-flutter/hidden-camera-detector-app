import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';
import '../repositories/subscription_repository.dart';

class PurchaseSubscriptionUseCase {
  const PurchaseSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Either<Failure, bool>> call() {
    return _repository.purchaseSubscription();
  }
}
