// features/reclamation/data/models/reclamation_model.dart
import 'package:sime_v2/features/reclamation/domain/entities/reclamation_entity.dart';

/// Compte utilisateur impliqué dans une réclamation.
class ClaimUserModel extends ClaimUserEntity {
  const ClaimUserModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.email,
    super.phone,
    super.avatarUrl,
  });

  /// Depuis l'objet `applicant.userJson` (le compte du demandeur).
  factory ClaimUserModel.fromUserJson(Map<String, dynamic> json) {
    return ClaimUserModel(
      id: (json['id'] as int?) ?? (json['applicantId'] as int?) ?? 0,
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  /// Depuis un objet `agent` — forme non confirmée : on parse les champs usuels
  /// de façon défensive, avec repli sur un `userJson` imbriqué s'il existe.
  factory ClaimUserModel.fromAgentJson(Map<String, dynamic> json) {
    final nested = json['userJson'];
    final source = nested is Map<String, dynamic> ? nested : json;
    return ClaimUserModel(
      id: (source['id'] as int?) ?? 0,
      firstName: source['firstName']?.toString(),
      lastName: source['lastName']?.toString(),
      email: source['email']?.toString(),
      phone: source['phone']?.toString(),
      avatarUrl: source['avatarUrl']?.toString(),
    );
  }
}

/// Un élément de `claimResponse`.
class ClaimResponseModel extends ClaimMessageEntity {
  const ClaimResponseModel({
    super.id,
    required super.content,
    required super.author,
    super.delivery,
    super.agent,
  });

  /// Attribution défensive (voir [ClaimAuthor]) : une réponse est considérée
  /// comme émise par le demandeur uniquement si le backend le marque
  /// explicitement (`byApplicant == true` ou présence d'un objet `applicant`) ;
  /// sinon elle est attribuée au conseiller — ce qui correspond aux payloads
  /// observés (`claimResponse` = réponses du service au demandeur).
  factory ClaimResponseModel.fromJson(Map<String, dynamic> json) {
    final agentJson = json['agent'];
    final byApplicant =
        json['byApplicant'] == true || json['applicant'] != null;
    return ClaimResponseModel(
      id: json['id'] as int?,
      content: (json['message'] ?? '').toString(),
      author: byApplicant ? ClaimAuthor.applicant : ClaimAuthor.agent,
      delivery: ClaimDelivery.sent,
      agent: agentJson is Map<String, dynamic>
          ? ClaimUserModel.fromAgentJson(agentJson)
          : null,
    );
  }
}

/// Une réclamation complète.
class ClaimRequestModel extends ClaimRequestEntity {
  /// JSON brut d'origine, conservé pour un round-trip Hive fidèle (même pattern
  /// que `RdvModel.rawJson` / `ApplicantModel.rawJson`).
  final Map<String, dynamic> rawJson;

  const ClaimRequestModel({
    required super.id,
    super.active,
    required super.message,
    super.applicant,
    super.applicantId,
    super.agent,
    super.agentId,
    super.subscriptionId,
    super.responses,
    required this.rawJson,
  });

  factory ClaimRequestModel.fromJson(Map<String, dynamic> json) {
    final applicantJson = json['applicant'] as Map<String, dynamic>?;
    final userJson = applicantJson?['userJson'] as Map<String, dynamic>?;
    final agentJson = json['agent'];
    final subscriptionJson = json['subscription'];
    final responsesJson = json['claimResponse'] as List<dynamic>? ?? const [];

    return ClaimRequestModel(
      id: (json['id'] as int?) ?? 0,
      active: json['status'] as bool? ?? true,
      message: (json['message'] ?? '').toString(),
      applicant:
          userJson != null ? ClaimUserModel.fromUserJson(userJson) : null,
      applicantId:
          (applicantJson?['id'] as int?) ?? (json['applicantId'] as int?),
      agent: agentJson is Map<String, dynamic>
          ? ClaimUserModel.fromAgentJson(agentJson)
          : null,
      agentId: json['agentId'] as int?,
      subscriptionId: subscriptionJson is Map<String, dynamic>
          ? subscriptionJson['id'] as int?
          : null,
      responses: responsesJson
          .whereType<Map<String, dynamic>>()
          .map(ClaimResponseModel.fromJson)
          .toList(),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}
