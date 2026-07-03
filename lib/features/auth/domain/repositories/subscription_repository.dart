import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/auth/domain/entities/subscription_entity.dart';

abstract interface class SubscriptionRepository {
  /// GET /api/subscriptions/me
  Future<Either<Failure, List<SubscriptionEntity>>> getMySubscriptions();
 
  /// POST /api/subscriptions
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required int typeServiceId,
    required int serviceId,
    int? partnerServiceId,
  });
}