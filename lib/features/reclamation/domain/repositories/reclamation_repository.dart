// features/reclamation/domain/repositories/reclamation_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/reclamation/domain/entities/reclamation_entity.dart';

/// Résultat d'un envoi (création de réclamation ou réponse) : distingue un
/// envoi réellement acheminé au serveur d'un envoi mis en file d'attente
/// hors-ligne, pour que l'UI affiche l'accusé approprié.
enum ClaimSendOutcome { sent, queued }

/// Contrat de la fonctionnalité Réclamations.
///
/// Périmètre : lecture offline-first de la liste, création d'une réclamation,
/// et ajout d'une réponse du demandeur dans un fil existant (envoi optimiste +
/// file d'attente hors-ligne). Voir `ReclamationRemoteDataSource` pour l'état
/// (confirmé / présumé) de chaque endpoint.
abstract interface class ReclamationRepository {
  /// GET /applicant/api/claim-request-applicants/me — liste offline-first.
  Future<Either<Failure, List<ClaimRequestEntity>>> getMyClaims();

  /// Crée une nouvelle réclamation (message d'ouverture). Hors-ligne : mise en
  /// file d'attente locale ([ClaimSendOutcome.queued]).
  Future<Either<Failure, ClaimSendOutcome>> createClaim({
    required String message,
    required int applicantId,
  });

  /// Ajoute une réponse du demandeur à une réclamation existante. Hors-ligne :
  /// mise en file d'attente locale.
  Future<Either<Failure, ClaimSendOutcome>> sendReply({
    required int claimId,
    required String message,
    required int applicantId,
  });

  /// Messages locaux du demandeur pour une réclamation donnée (envois
  /// optimistes, y compris ceux encore en file d'attente).
  Future<List<ClaimMessageEntity>> localMessagesFor(int claimId);

  /// Réclamations créées hors-ligne, pas encore synchronisées (affichage
  /// optimiste en tête de liste).
  Future<List<ClaimMessageEntity>> pendingNewClaims();

  /// Rejoue la file d'attente hors-ligne (réclamations + réponses).
  Future<void> synchronizeOfflineData();
}
