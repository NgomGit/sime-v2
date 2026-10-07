// features/offres/data/repository/external_offer_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/offres/data/datasources/external_offer_datasource.dart';
import 'package:sime_v2/features/offres/data/models/job_offer_model.dart';
import 'package:sime_v2/features/offres/domain/entities/job_offer_entity.dart';
import 'package:sime_v2/features/offres/domain/repositories/external_offer_repository.dart';

class ExternalOfferRepositoryImpl
    with OfflineFirstMixin
    implements ExternalOfferRepository {
  const ExternalOfferRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });

  final ExternalOfferRemoteDataSource remote;

  @override
  final NetworkInfo networkInfo;

  @override
  final HiveCache cache;

  @override
  Future<Either<Failure, List<JobOfferEntity>>> getAvailableOffers({
    int page = 1,
    int size = 10,
  }) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.externalOffers,
        remoteCall: () => remote.getAvailableOffers(page: page, size: size),
        fromCache: (j) => listFromCache(j, JobOfferModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<JobOfferModel>(), (m) => m.toJson()),
      );
}
