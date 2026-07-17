// features/rendezvous/domain/entities/rdv_entity.dart
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';

/// Statuts possibles d'un rendez-vous côté backend (champ `statusRdv`).
///
/// Seule la valeur `ACCEPTED` a été observée dans un payload réel à ce jour
/// (GET /rdv/api/rdvs/me). Les autres valeurs ci-dessous couvrent le cycle de
/// vie standard d'une prise de RDV (hypothèse raisonnable, à ajuster dès
/// qu'un payload le confirme) ; [unknown] sert de filet de sécurité pour ne
/// jamais planter sur une valeur imprévue — l'UI retombe alors sur
/// [RdvEntity.rawStatusRdv] plutôt que sur un libellé figé et faux.
enum RdvStatus {
  pending,
  accepted,
  refused,
  cancelled,
  completed,
  rescheduled,
  unknown;

  static RdvStatus fromRaw(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'PENDING':
      case 'EN_ATTENTE':
      case 'REQUESTED':
        return RdvStatus.pending;
      case 'ACCEPTED':
      case 'CONFIRMED':
      case 'VALIDATED':
        return RdvStatus.accepted;
      case 'REFUSED':
      case 'REJECTED':
        return RdvStatus.refused;
      case 'CANCELLED':
      case 'CANCELED':
      case 'ANNULE':
      case 'ANNULEE':
        return RdvStatus.cancelled;
      case 'DONE':
      case 'COMPLETED':
      case 'TERMINE':
      case 'TERMINEE':
        return RdvStatus.completed;
      case 'RESCHEDULED':
      case 'REPROGRAMME':
      case 'REPROGRAMMED':
        return RdvStatus.rescheduled;
      default:
        return RdvStatus.unknown;
    }
  }

  /// Un statut "actif" compte encore comme un rendez-vous à honorer — sert à
  /// distinguer "à venir" de "annulé/refusé dans le futur", qui ne doit pas
  /// apparaître comme un prochain rendez-vous malgré une date future.
  bool get isActive => this != RdvStatus.cancelled && this != RdvStatus.refused;
}

/// Conseiller/agent ANPEJ affecté au rendez-vous.
///
/// `null` tant que le RDV n'a pas encore été pris en charge par un agent
/// (cas observé dans le payload réel : `agent: null`, `agentId: null`).
class RdvAgentEntity {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  const RdvAgentEntity({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  String get fullName {
    final parts = [firstName, lastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .cast<String>()
        .toList();
    return parts.isEmpty ? 'Conseiller ANPEJ' : parts.join(' ');
  }

  String get initials {
    final words = fullName.trim().split(RegExp(r'\s+'));
    final letters = words.where((w) => w.isNotEmpty).map((w) => w[0]).take(2);
    return letters.join().toUpperCase();
  }
}

/// Un rendez-vous du candidat (ANPEJ) — GET /rdv/api/rdvs/me.
///
/// NB : le payload réel imbrique aussi l'objet `applicant` complet (le
/// candidat connecté lui-même) — volontairement ignoré ici : c'est une
/// redondance avec `ApplicantNotifier`/`ApplicantEntity`, pas une donnée
/// propre au rendez-vous, et l'embarquer alourdirait inutilement le cache.
class RdvEntity {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Champ `status` (bool) du backend — état actif/archivé de la ligne, à ne
  /// pas confondre avec [statusRdv] (le statut métier du rendez-vous).
  final bool active;

  final DateTime startAt;
  final DateTime endAt;

  final RdvStatus statusRdv;

  /// Valeur brute renvoyée par l'API pour `statusRdv`, conservée telle
  /// quelle pour l'affichage de secours si elle ne correspond à aucun
  /// [RdvStatus] connu (voir [RdvStatus.fromRaw]).
  final String rawStatusRdv;

  final String? tokenRdv;
  final String? applicantObservation;
  final String? agentObservation;

  final int? applicantId;

  final int? officeId;
  final OfficeEntity? office;

  final int? agentId;
  final int? agentUserId;
  final RdvAgentEntity? agent;

  final int? rescheduledFromId;
  final String? rescheduleReason;

  const RdvEntity({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.active = true,
    required this.startAt,
    required this.endAt,
    required this.statusRdv,
    required this.rawStatusRdv,
    this.tokenRdv,
    this.applicantObservation,
    this.agentObservation,
    this.applicantId,
    this.officeId,
    this.office,
    this.agentId,
    this.agentUserId,
    this.agent,
    this.rescheduledFromId,
    this.rescheduleReason,
  });

  bool get isUpcoming => startAt.isAfter(DateTime.now()) && statusRdv.isActive;
  bool get isPast => !isUpcoming;
  bool get hasAgent => agent != null;
  bool get wasRescheduled => rescheduledFromId != null;
  Duration get duration => endAt.difference(startAt);
}
