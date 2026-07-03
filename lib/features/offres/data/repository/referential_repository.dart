
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/offres/data/datasources/referential_datasource.dart';
import 'package:sime_v2/features/offres/data/models/referential_model.dart';
import 'package:sime_v2/features/offres/domain/entities/referential_entity.dart';
import 'package:sime_v2/features/offres/domain/repositories/anpej_referential_repository.dart';

class ReferentielRepositoryImpl
    with OfflineFirstMixin
    implements ReferentielRepository {
  const ReferentielRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });
 
  final ReferentielRemoteDataSource remote;
 
  @override final NetworkInfo networkInfo;
  @override final HiveCache cache;
 
  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() => offlineFirst(
        cacheKey: HiveCacheKeys.countries,
        remoteCall: remote.getCountries,
        fromCache: (j) => listFromCache(j, CountryModel.fromJson),
        toJson: (l) => listToJson(l.cast<CountryModel>(), (c) => c.toJson()),
      );
 
  @override
  Future<Either<Failure, List<RegionEntity>>> getRegions() => offlineFirst(
        cacheKey: HiveCacheKeys.regions,
        remoteCall: remote.getRegions,
        fromCache: (j) => listFromCache(j, RegionModel.fromJson),
        toJson: (l) => listToJson(l.cast<RegionModel>(), (r) => r.toJson()),
      );
 
  @override
  Future<Either<Failure, List<DepartmentEntity>>> getDepartments(
    int regionId,
  ) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.departments(regionId),
        remoteCall: () => remote.getDepartments(regionId),
        fromCache: (j) => listFromCache(j, DepartmentModel.fromJson),
        toJson: (l) =>
            listToJson(l.cast<DepartmentModel>(), (d) => d.toJson()),
      );
 
  @override
  Future<Either<Failure, List<MunicipalityEntity>>> getMunicipalities(
    int departmentId,
  ) =>
      offlineFirst(
        cacheKey: HiveCacheKeys.municipalities(departmentId),
        remoteCall: () => remote.getMunicipalities(departmentId),
        fromCache: (j) => listFromCache(j, MunicipalityModel.fromJson),
        toJson: (l) =>
            listToJson(l.cast<MunicipalityModel>(), (m) => m.toJson()),
      );
 
  @override
  Future<Either<Failure, List<EducationLevelEntity>>> getEducationLevels() =>
      offlineFirst(
        cacheKey: HiveCacheKeys.educationLevels,
        remoteCall: remote.getEducationLevels,
        fromCache: (j) => listFromCache(j, EducationLevelModel.fromJson),
        toJson: (l) =>
            listToJson(l.cast<EducationLevelModel>(), (e) => e.toJson()),
      );
 
  @override
  Future<Either<Failure, List<DegreeEntity>>> getDegrees() => offlineFirst(
        cacheKey: HiveCacheKeys.degrees,
        remoteCall: remote.getDegrees,
        fromCache: (j) => listFromCache(j, DegreeModel.fromJson),
        toJson: (l) =>
            listToJson(l.cast<DegreeModel>(), (d) => d.toJson()),
      );
}