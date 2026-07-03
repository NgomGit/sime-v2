
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/rendezvous/domain/entities/rdv_entity.dart';

abstract interface class RdvRepository {
  /// GET /api/rdvs/me
  Future<Either<Failure, List<RdvEntity>>> getMyRdvs();
 
  /// POST /api/rdvs
  Future<Either<Failure, RdvEntity>> createRdv({
    required DateTime startAt,
    required DateTime endAt,
    required int agentId,
    required int officeId,
    required int typeServiceId,
    required int serviceId,
    String? observation,
  });
 
  /// GET /api/rdvs/me/auto
  Future<Either<Failure, RdvEntity>> autoBookRdv();
 
  /// PATCH /api/rdvs/{id}
  Future<Either<Failure, RdvEntity>> updateRdvStatus({
    required int id,
    required String status,
  });
}