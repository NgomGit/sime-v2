// features/offres/domain/repositories/training_offer_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/offres/domain/entities/training_offer_entity.dart';

/// Contrat des offres de formation — lectures offline-first (cache Hive).
abstract interface class TrainingOfferRepository {
  /// GET /applicant/api/training-offers/available
  Future<Either<Failure, List<TrainingOfferEntity>>> getAvailableOffers({
    int page,
    int size,
  });

  /// GET /applicant/api/training-offers/{id}/available
  Future<Either<Failure, TrainingOfferEntity>> getOfferDetail(int id);
}
