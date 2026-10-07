// features/besoin/domain/repositories/besoin_repository.dart
import 'package:dartz/dartz.dart';

import 'package:sime_v2/core/error/failures.dart';

import '../entities/besoin_entities.dart';
import '../entities/my_subscription_entity.dart';

/// Contrat du parcours « Nouveau besoin ».
///
/// Lectures (listes en cascade) → offline-first : servies depuis le cache Hive
/// quand le réseau est indisponible (voir `OfflineFirstMixin.offlineFirst`).
///
/// Écriture (création de la souscription) → réseau uniquement : renvoie
/// [NetworkFailure] immédiatement hors-ligne (voir
/// `OfflineFirstMixin.remoteOnly`). On ne met pas la création en file d'attente
/// hors-ligne pour l'instant : le contrat exact de POST /subscriptions/me
/// (idempotence, dédoublonnage) n'est pas confirmé, et rejouer en aveugle
/// risquerait de créer des doublons de dossier côté ANPEJ.
abstract interface class BesoinRepository {
  Future<Either<Failure, List<TypeServiceEntity>>> getPossibleTypeServices();

  Future<Either<Failure, List<PartnerServiceEntity>>> getPossiblePartnerServices(
    int typeServiceId,
  );

  Future<Either<Failure, List<ServiceOfferEntity>>> getPossibleServices({
    required int partnerServiceId,
    required int typeServiceId,
  });

  Future<Either<Failure, Map<String, dynamic>>> createSubscription(
    Map<String, dynamic> payload,
  );

  /// Modifie un besoin existant (réseau uniquement).
  Future<Either<Failure, Unit>> updateSubscription(
    int id,
    Map<String, dynamic> payload,
  );

  /// Supprime un besoin (réseau uniquement — une suppression hors-ligne
  /// rejouée plus tard pourrait viser un dossier déjà pris en charge).
  Future<Either<Failure, Unit>> deleteSubscription(int id);

  /// Liste des besoins déjà sollicités (offline-first).
  Future<Either<Failure, List<MySubscriptionEntity>>> getMySubscriptions();
}
