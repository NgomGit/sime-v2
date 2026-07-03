
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/offres/data/datasources/anpej_service_datasource.dart';
import 'package:sime_v2/features/offres/data/models/anpej_service_model.dart';
import 'package:sime_v2/features/offres/domain/entities/anpej_service_entity.dart';
import 'package:sime_v2/features/offres/domain/repositories/anpej_service_repository.dart';

class AnpejServiceRepositoryImpl
    with OfflineFirstMixin
    implements AnpejServiceRepository {
  const AnpejServiceRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });
 
  final AnpejServiceRemoteDataSource remote;
 
  @override final NetworkInfo networkInfo;
  @override final HiveCache cache;
 
  @override
  Future<Either<Failure, List<AnpejServiceEntity>>> getAllServices() =>
      offlineFirst(
        cacheKey: HiveCacheKeys.services,
        remoteCall: remote.getAllServices,
        fromCache: (j) => listFromCache(j, AnpejServiceModel.fromJson),
        toJson: (list) => listToJson(
          list.cast<AnpejServiceModel>(),
          (s) => s.toJson(),
        ),
      );
 
  @override
  Future<Either<Failure, List<AnpejServiceEntity>>> getServicesForMe() =>
      offlineFirst(
        cacheKey: HiveCacheKeys.servicesForMe,
        remoteCall: remote.getServicesForMe,
        fromCache: (j) => listFromCache(j, AnpejServiceModel.fromJson),
        toJson: (list) => listToJson(
          list.cast<AnpejServiceModel>(),
          (s) => s.toJson(),
        ),
      );
}