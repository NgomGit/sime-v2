
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/offres/data/datasources/job_offer_datasource.dart';
import 'package:sime_v2/features/offres/data/models/job_offer_model.dart';
import 'package:sime_v2/features/offres/domain/entities/job_offer_entity.dart';
import 'package:sime_v2/features/offres/domain/repositories/job_offer_repository.dart';

class JobOfferRepositoryImpl
    with OfflineFirstMixin
    implements JobOfferRepository {
  const JobOfferRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });
 
  final JobOfferRemoteDataSource remote;
 
  @override final NetworkInfo networkInfo;
  @override final HiveCache cache;
 
  @override
  Future<Either<Failure, List<JobOfferEntity>>> getAvailableOffers() =>
      offlineFirst(
        cacheKey: HiveCacheKeys.jobOffers,
        remoteCall: remote.getAvailableOffers,
        fromCache: (j) => listFromCache(j, JobOfferModel.fromJson),
        toJson: (list) => listToJson(
          list.cast<JobOfferModel>(),
          (o) => o.toJson(),
        ),
      );
}