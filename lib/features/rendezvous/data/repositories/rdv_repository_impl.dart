
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/rendezvous/data/datasources/rdv_datasource.dart';
import 'package:sime_v2/features/rendezvous/data/models/rdv_model.dart';
import 'package:sime_v2/features/rendezvous/domain/entities/rdv_entity.dart';
import 'package:sime_v2/features/rendezvous/domain/repositories/rdv_repository.dart';

class RdvRepositoryImpl with OfflineFirstMixin implements RdvRepository {
  const RdvRepositoryImpl({
    required this.remote,
    required this.networkInfo,
    required this.cache,
  });
 
  final RdvRemoteDataSource remote;
 
  @override final NetworkInfo networkInfo;
  @override final HiveCache cache;
 
  @override
  Future<Either<Failure, List<RdvModel>>> getMyRdvs() => offlineFirst(
        cacheKey: HiveCacheKeys.rdvsMe,
        remoteCall: remote.getMyRdvs,
        fromCache: (j) => listFromCache(j, RdvModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<RdvModel>(), (r) => r.toJson()),
      );
 
  @override
  Future<Either<Failure, RdvEntity>> createRdv({
    required DateTime startAt,
    required DateTime endAt,
    required int agentId,
    required int officeId,
    required int typeServiceId,
    required int serviceId,
    String? observation,
  }) async {
    final result = await remoteOnly(
      () => remote.createRdv({
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'agentId': agentId,
        'officeId': officeId,
        'typeServiceId': typeServiceId,
        'serviceId': serviceId,
        if (observation != null) 'applicantObservation': observation,
      }),
    );
    if (result.isRight()) await invalidate(HiveCacheKeys.rdvsMe);
    return result;
  }
 
  @override
  Future<Either<Failure, RdvEntity>> autoBookRdv() async {
    final result = await remoteOnly(remote.autoBookRdv);
    if (result.isRight()) await invalidate(HiveCacheKeys.rdvsMe);
    return result;
  }
 
  @override
  Future<Either<Failure, RdvEntity>> updateRdvStatus({
    required int id,
    required String status,
  }) async {
    final result = await remoteOnly(
      () => remote.updateRdvStatus(id, {'statusRdv': status}),
    );
    if (result.isRight()) await invalidate(HiveCacheKeys.rdvsMe);
    return result;
  }
}