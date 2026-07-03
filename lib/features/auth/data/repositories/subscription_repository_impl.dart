
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/auth/data/datasources/subscription_datasource.dart';
import 'package:sime_v2/features/auth/data/models/subscription_model.dart';
import 'package:sime_v2/features/auth/domain/entities/subscription_entity.dart';
import 'package:sime_v2/features/auth/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl
    with OfflineFirstMixin
    implements SubscriptionRepository {
  const SubscriptionRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });
 
  final SubscriptionRemoteDataSource remote;
 
  @override final NetworkInfo networkInfo;
  @override final HiveCache cache;
 
  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getMySubscriptions() =>
      offlineFirst(
        cacheKey: HiveCacheKeys.subscriptionsMe,
        remoteCall: remote.getMySubscriptions,
        fromCache: (j) => listFromCache (j, SubscriptionModel.fromJson),
        toJson: (list) => listToJson(
          list.cast<SubscriptionModel>(),
          (s) => s.toJson(),
        ),
      );
 
  @override
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required int typeServiceId,
    required int serviceId,
    int? partnerServiceId,
  }) async {
    final result = await remoteOnly(
      () => remote.createSubscription({
        'typeService': {'id': typeServiceId},
        'service': {'id': serviceId},
        if (partnerServiceId != null)
          'partnerService': {'id': partnerServiceId},
      }),
    );
    if (result.isRight()) await invalidate(HiveCacheKeys.subscriptionsMe);
    return result;
  }
}