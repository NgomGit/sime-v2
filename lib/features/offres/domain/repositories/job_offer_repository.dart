import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/offres/domain/entities/job_offer_entity.dart';

abstract interface class JobOfferRepository {
  /// GET /api/job-offers/available
  Future<Either<Failure, List<JobOfferEntity>>> getAvailableOffers();
}