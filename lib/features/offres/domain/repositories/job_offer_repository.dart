// features/offres/domain/repositories/job_offer_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/offres/domain/entities/job_application_entity.dart';
import 'package:sime_v2/features/offres/domain/entities/job_offer_entity.dart';

/// Contrat des offres d'emploi — lectures offline-first (cache Hive).
abstract interface class JobOfferRepository {
  /// GET /applicant/api/job-offers/available
  Future<Either<Failure, List<JobOfferEntity>>> getAvailableOffers({
    int page,
    int size,
  });

  /// GET /applicant/api/job-offers/{id}/available
  Future<Either<Failure, JobOfferEntity>> getOfferDetail(int id);

  /// POST /applicant/api/job-offer-applicants/me — postuler à une offre d'emploi.
  Future<Either<Failure, JobApplicationEntity>> applyToOffer({
    required int applicantId,
    required int jobOfferId,
  });
}
