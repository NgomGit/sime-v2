// features/offres/domain/repositories/external_offer_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/offres/domain/entities/job_offer_entity.dart';

/// Contrat des offres d'emploi externes (mise en relation) — lecture
/// offline-first. Réutilise [JobOfferEntity] (même structure d'offre).
abstract interface class ExternalOfferRepository {
  /// GET /applicant/api/job-linking-offer-applicants/me
  Future<Either<Failure, List<JobOfferEntity>>> getAvailableOffers({
    int page,
    int size,
  });
}
