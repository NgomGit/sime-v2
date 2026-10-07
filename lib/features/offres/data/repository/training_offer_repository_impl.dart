// features/offres/data/repository/training_offer_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/offres/data/datasources/training_offer_datasource.dart';
import 'package:sime_v2/features/offres/data/models/training_offer_model.dart';
import 'package:sime_v2/features/offres/domain/entities/training_offer_entity.dart';
import 'package:sime_v2/features/offres/domain/repositories/training_offer_repository.dart';

class TrainingOfferRepositoryImpl
    with OfflineFirstMixin
    implements TrainingOfferRepository {
  const TrainingOfferRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });

  final TrainingOfferRemoteDataSource remote;

  @override
  final NetworkInfo networkInfo;

  @override
  final HiveCache cache;

  @override
  Future<Either<Failure, List<TrainingOfferEntity>>> getAvailableOffers({
    int page = 1,
    int size = 20,
  }) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.trainingOffers,
        remoteCall: () => remote.getAvailableOffers(page: page, size: size),
        fromCache: (j) => listFromCache(j, TrainingOfferModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<TrainingOfferModel>(), (m) => m.toJson()),
      );

  @override
  Future<Either<Failure, TrainingOfferEntity>> getOfferDetail(int id) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.trainingOffer(id),
        remoteCall: () => remote.getOfferDetail(id),
        fromCache: (j) => TrainingOfferModel.fromJson(j as Map<String, dynamic>),
        toJson: (o) => (o as TrainingOfferModel).toJson(),
      );
}
