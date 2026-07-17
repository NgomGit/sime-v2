// features/rendezvous/data/models/rdv_model.dart
import 'package:sime_v2/features/profile/data/models/applicant_model.dart';
import 'package:sime_v2/features/rendezvous/domain/entities/rdv_entity.dart';

class RdvAgentModel extends RdvAgentEntity {
  RdvAgentModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.phone,
    super.email,
    super.avatarUrl,
  });

  factory RdvAgentModel.fromJson(Map<String, dynamic> json) => RdvAgentModel(
        id: json['id'] as int? ?? 0,
        firstName: json['firstName']?.toString(),
        lastName: json['lastName']?.toString(),
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
      );
}

class RdvModel extends RdvEntity {
  /// JSON brut d'origine, conservé pour un cache Hive fidèle (round-trip)
  /// sans avoir à réécrire manuellement la sérialisation de chaque sous-objet
  /// imbriqué (office, agent...) — même pattern que `ApplicantModel.rawJson`.
  final Map<String, dynamic> rawJson;

  RdvModel({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    super.active,
    required super.startAt,
    required super.endAt,
    required super.statusRdv,
    required super.rawStatusRdv,
    super.tokenRdv,
    super.applicantObservation,
    super.agentObservation,
    super.applicantId,
    super.officeId,
    super.office,
    super.agentId,
    super.agentUserId,
    super.agent,
    super.rescheduledFromId,
    super.rescheduleReason,
    required this.rawJson,
  });

  factory RdvModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['statusRdv']?.toString();

    return RdvModel(
      id: json['id'] as int,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      active: json['status'] as bool? ?? true,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      statusRdv: RdvStatus.fromRaw(rawStatus),
      rawStatusRdv: rawStatus ?? '',
      tokenRdv: json['tokenRdv']?.toString(),
      applicantObservation: json['applicantObservation']?.toString(),
      agentObservation: json['agentObservation']?.toString(),
      applicantId: json['applicantId'] as int?,
      officeId: json['officeId'] as int?,
      office: json['office'] != null
          ? OfficeModel.fromJson(json['office'] as Map<String, dynamic>)
          : null,
      agentId: json['agentId'] as int?,
      agentUserId: json['agentUserId'] as int?,
      agent: json['agent'] != null
          ? RdvAgentModel.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      rescheduledFromId: json['rescheduledFromId'] as int?,
      rescheduleReason: json['rescheduleReason']?.toString(),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}
