// features/besoin/data/repositories/besoin_repository_impl.dart
import 'package:dartz/dartz.dart';

import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';

import '../../domain/repositories/besoin_repository.dart';
import '../datasources/besoin_remote_datasource.dart';
import '../models/besoin_models.dart';
import '../models/my_subscription_model.dart';

class BesoinRepositoryImpl with OfflineFirstMixin implements BesoinRepository {
  const BesoinRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });

  final BesoinRemoteDataSource remote;

  @override
  final NetworkInfo networkInfo;

  @override
  final HiveCache cache;

  @override
  Future<Either<Failure, List<TypeServiceModel>>> getPossibleTypeServices() =>
      offlineFirst(
        cacheKey: HiveCacheKeys.typeServicesPossible,
        remoteCall: remote.getPossibleTypeServices,
        fromCache: (j) => listFromCache(j, TypeServiceModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<TypeServiceModel>(), (m) => m.toJson()),
      );

  @override
  Future<Either<Failure, List<PartnerServiceModel>>> getPossiblePartnerServices(
    int typeServiceId,
  ) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.partnerServicesPossible(typeServiceId),
        remoteCall: () => remote.getPossiblePartnerServices(typeServiceId),
        fromCache: (j) => listFromCache(j, PartnerServiceModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<PartnerServiceModel>(), (m) => m.toJson()),
      );

  @override
  Future<Either<Failure, List<ServiceOfferModel>>> getPossibleServices({
    required int partnerServiceId,
    required int typeServiceId,
  }) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.servicesPossible(partnerServiceId, typeServiceId),
        remoteCall: () => remote.getPossibleServices(
          partnerServiceId: partnerServiceId,
          typeServiceId: typeServiceId,
        ),
        fromCache: (j) => listFromCache(j, ServiceOfferModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<ServiceOfferModel>(), (m) => m.toJson()),
      );

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSubscription(
    Map<String, dynamic> payload,
  ) =>
      remoteOnly(() => remote.createSubscription(payload));

  @override
  Future<Either<Failure, Unit>> updateSubscription(
    int id,
    Map<String, dynamic> payload,
  ) =>
      remoteOnly(() async {
        await remote.updateSubscription(id, payload);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteSubscription(int id) =>
      remoteOnly(() async {
        await remote.deleteSubscription(id);
        return unit;
      });

  @override
  Future<Either<Failure, List<MySubscriptionModel>>> getMySubscriptions() =>
      offlineFirst(
        cacheKey: HiveCacheKeys.subscriptionsMe,
        remoteCall: remote.getMySubscriptions,
        fromCache: (j) => listFromCache(j, MySubscriptionModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<MySubscriptionModel>(), (m) => m.toJson()),
      );
}
