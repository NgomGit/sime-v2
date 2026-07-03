 
import 'package:sime_v2/features/rendezvous/domain/entities/rdv_entity.dart';

class RdvModel extends RdvEntity {
  const RdvModel({
    required super.id,
    required super.startAt,
    required super.status,
    super.endAt,
    super.agentId,
    super.tokenRdv,
    super.applicantObservation,
  });
 
  factory RdvModel.fromJson(Map<String, dynamic> json) => RdvModel(
        id: json['id'] as int,
        startAt: DateTime.parse(json['startAt'] as String),
        status: RdvStatus.fromString(
          json['statusRdv'] as String? ?? 'PENDING',
        ),
        endAt: json['endAt'] != null
            ? DateTime.parse(json['endAt'] as String)
            : null,
        agentId: json['agentId'] as int?,
        tokenRdv: json['tokenRdv'] as String?,
        applicantObservation: json['applicantObservation'] as String?,
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'startAt': startAt.toIso8601String(),
        'statusRdv': status.name.toUpperCase(),
        if (endAt != null) 'endAt': endAt!.toIso8601String(),
        if (agentId != null) 'agentId': agentId,
        if (tokenRdv != null) 'tokenRdv': tokenRdv,
      };
}