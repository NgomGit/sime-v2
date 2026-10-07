// features/offres/data/repository/job_offer_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/offres/data/datasources/job_offer_datasource.dart';
import 'package:sime_v2/features/offres/data/models/job_offer_model.dart';
import 'package:sime_v2/features/offres/domain/entities/job_application_entity.dart';
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

  @override
  final NetworkInfo networkInfo;

  @override
  final HiveCache cache;

  @override
  Future<Either<Failure, List<JobOfferEntity>>> getAvailableOffers({
    int page = 1,
    int size = 20,
  }) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.jobOffers,
        remoteCall: () => remote.getAvailableOffers(page: page, size: size),
        fromCache: (j) => listFromCache(j, JobOfferModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<JobOfferModel>(), (m) => m.toJson()),
      );

  @override
  Future<Either<Failure, JobOfferEntity>> getOfferDetail(int id) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.jobOffer(id),
        remoteCall: () => remote.getOfferDetail(id),
        fromCache: (j) => JobOfferModel.fromJson(j as Map<String, dynamic>),
        toJson: (o) => (o as JobOfferModel).toJson(),
      );

  @override
  Future<Either<Failure, JobApplicationEntity>> applyToOffer({
    required int applicantId,
    required int jobOfferId,
  }) =>
      remoteOnly<JobApplicationEntity>(
        () => remote.applyToOffer(
          applicantId: applicantId,
          jobOfferId: jobOfferId,
        ),
      );
}
