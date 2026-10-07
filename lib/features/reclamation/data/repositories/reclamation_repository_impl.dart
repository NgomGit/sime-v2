// features/reclamation/data/repositories/reclamation_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/caching.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';

import '../../domain/entities/reclamation_entity.dart';
import '../../domain/repositories/reclamation_repository.dart';
import '../datasources/reclamation_local_datasource.dart';
import '../datasources/reclamation_remote_datasource.dart';
import '../models/reclamation_model.dart';

class ReclamationRepositoryImpl with OfflineFirstMixin implements ReclamationRepository {
  ReclamationRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
    required this.cache,
  });

  final ReclamationRemoteDataSource remote;
  final ReclamationLocalDataSource local;

  @override
  final NetworkInfo networkInfo;

  @override
  final HiveCache cache;

  @override
  Future<Either<Failure, List<ClaimRequestModel>>> getMyClaims() => offlineFirst(
        cacheKey: HiveCacheKeys.claimRequestsMe,
        remoteCall: () => remote.getMyClaims(),
        fromCache: (j) => listFromCache(j, ClaimRequestModel.fromJson),
        toJson: (list) =>
            listToJson(list.cast<ClaimRequestModel>(), (m) => m.toJson()),
      );

  @override
  Future<Either<Failure, ClaimSendOutcome>> createClaim({
    required String message,
    required int applicantId,
  }) async {
    if (await networkInfo.isConnected) {
      final result = await remoteOnly<void>(
        () => remote.createClaim(message: message, applicantId: applicantId),
      );
      return result.fold(
        (failure) async {
          // Échec malgré la connexion → repli file d'attente (même stratégie
          // que ApplicantRepositoryImpl.updateApplicantProfile).
          await local.enqueueNewClaim(message: message, applicantId: applicantId);
          return const Right(ClaimSendOutcome.queued);
        },
        (_) async {
          await invalidate(HiveCacheKeys.claimRequestsMe);
          return const Right(ClaimSendOutcome.sent);
        },
      );
    }
    await local.enqueueNewClaim(message: message, applicantId: applicantId);
    return const Right(ClaimSendOutcome.queued);
  }

  @override
  Future<Either<Failure, ClaimSendOutcome>> sendReply({
    required int claimId,
    required String message,
    required int applicantId,
  }) async {
    // Toujours consigner localement d'abord : le serveur ne renvoie pas les
    // réponses du demandeur comme telles, le miroir local est donc la source
    // de vérité pour ré-afficher ce message + son accusé.
    final localId = await local.enqueueReply(
      claimId: claimId,
      message: message,
      applicantId: applicantId,
    );
    await local.saveLocalMessage(claimId, {
      'localId': localId,
      'message': message,
      'delivery': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });

    if (await networkInfo.isConnected) {
      final result = await remoteOnly<void>(
        () => remote.sendResponse(
          claimId: claimId,
          message: message,
          applicantId: applicantId,
        ),
      );
      return result.fold(
        (failure) async {
          // En ligne mais l'appel a échoué (ex. endpoint présumé non encore
          // disponible) : marquer « échec » et retirer de la file pour ne pas
          // marteler un endpoint cassé. L'UI propose un réessai manuel.
          await local.updateLocalMessageDelivery(claimId, localId, 'failed');
          await local.removeOutbox(localId);
          return Left(failure);
        },
        (_) async {
          await local.updateLocalMessageDelivery(claimId, localId, 'sent');
          await local.removeOutbox(localId);
          await invalidate(HiveCacheKeys.claimRequestsMe);
          return const Right(ClaimSendOutcome.sent);
        },
      );
    }
    // Hors-ligne : reste en file d'attente (pending) → sync au retour réseau.
    return const Right(ClaimSendOutcome.queued);
  }

  @override
  Future<List<ClaimMessageEntity>> localMessagesFor(int claimId) async {
    final raw = await local.getLocalMessages(claimId);
    return raw.map(_mapLocalMessage).toList();
  }

  @override
  Future<List<ClaimMessageEntity>> pendingNewClaims() async {
    final outbox = await local.getOutbox();
    return outbox
        .where((e) => e['type'] == 'new')
        .map(
          (e) => ClaimMessageEntity(
            localId: e['localId']?.toString(),
            content: (e['message'] ?? '').toString(),
            author: ClaimAuthor.applicant,
            delivery: ClaimDelivery.pending,
            sentAt: DateTime.tryParse(e['createdAt']?.toString() ?? ''),
          ),
        )
        .toList();
  }

  @override
  Future<void> synchronizeOfflineData() async {
    if (!(await networkInfo.isConnected)) return;
    final outbox = await local.getOutbox();
    if (outbox.isEmpty) return;

    var syncedSomething = false;
    for (final item in outbox) {
      final type = item['type']?.toString();
      final localId = item['localId']?.toString();
      final message = (item['message'] ?? '').toString();
      final applicantId = (item['applicantId'] as int?) ?? 0;
      if (localId == null || message.isEmpty || applicantId == 0) continue;

      try {
        if (type == 'new') {
          await remote.createClaim(message: message, applicantId: applicantId);
          await local.removeOutbox(localId);
          syncedSomething = true;
        } else if (type == 'reply') {
          final claimId = item['claimId'] as int?;
          if (claimId == null) continue;
          await remote.sendResponse(
            claimId: claimId,
            message: message,
            applicantId: applicantId,
          );
          await local.updateLocalMessageDelivery(claimId, localId, 'sent');
          await local.removeOutbox(localId);
          syncedSomething = true;
        }
      } catch (_) {
        // On laisse l'élément en file pour un prochain essai (retour réseau
        // suivant / réessai manuel).
      }
    }

    if (syncedSomething) {
      await invalidate(HiveCacheKeys.claimRequestsMe);
    }
  }

  ClaimMessageEntity _mapLocalMessage(Map<String, dynamic> m) {
    final deliveryStr = m['delivery']?.toString() ?? 'sent';
    return ClaimMessageEntity(
      id: m['id'] as int?,
      localId: m['localId']?.toString(),
      content: (m['message'] ?? '').toString(),
      author: ClaimAuthor.applicant,
      delivery: switch (deliveryStr) {
        'pending' => ClaimDelivery.pending,
        'failed' => ClaimDelivery.failed,
        _ => ClaimDelivery.sent,
      },
      sentAt: DateTime.tryParse(m['createdAt']?.toString() ?? ''),
    );
  }
}
