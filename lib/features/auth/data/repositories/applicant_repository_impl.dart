
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/auth/data/datasources/applicant_remote_datasource.dart';
import 'package:sime_v2/features/auth/data/models/applicant_model.dart';
import 'package:sime_v2/features/auth/domain/entities/applicant_entity.dart';
import 'package:sime_v2/features/auth/domain/repositories/application_repository.dart';

class ApplicantRepositoryImpl
    with OfflineFirstMixin
    implements ApplicantRepository {
  const ApplicantRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });
 
  final ApplicantRemoteDataSource remote;
 
  @override final NetworkInfo networkInfo;
  @override final HiveCache cache;
 
  @override
  Future<Either<Failure, ApplicantEntity>> getMyProfile() async {
    return offlineFirst(
      cacheKey: HiveCacheKeys.applicantMe,
      remoteCall: remote.getMyProfile,
      fromCache: (j) => ApplicantModel.fromJson(j as Map<String, dynamic>) as ApplicantEntity,
      toJson: (a) => (a as ApplicantModel).toJson(),
    );
  }
 
  @override
  Future<Either<Failure, ApplicantEntity>> registerApplicant(
    Map<String, dynamic> body,
  ) async {
    final result = await remoteOnly(() => remote.registerApplicant(body));
    if (result.isRight()) await invalidate(HiveCacheKeys.applicantMe);
    return result;
  }
 
  @override
  Future<Either<Failure, ApplicantEntity>> updateMyProfile(
    Map<String, dynamic> body,
  ) async {
    final result = await remoteOnly(() => remote.updateMyProfile(body));
    if (result.isRight()) await invalidate(HiveCacheKeys.applicantMe);
    return result;
  }
}