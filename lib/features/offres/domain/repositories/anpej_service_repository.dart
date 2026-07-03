
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/offres/domain/entities/anpej_service_entity.dart';

abstract interface class AnpejServiceRepository {
  /// GET /api/services
  Future<Either<Failure, List<AnpejServiceEntity>>> getAllServices();
 
  /// GET /api/services/possible-for-me
  Future<Either<Failure, List<AnpejServiceEntity>>> getServicesForMe();
}