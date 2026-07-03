
import 'package:sime_v2/features/offres/domain/entities/job_offer_entity.dart';

class JobOfferModel extends JobOfferEntity {
  const JobOfferModel({
    required super.id,
    required super.title,
    required super.status,
    super.description,
    super.location,
    super.contractType,
    super.deadline,
    super.partnerId,
  });
 
  factory JobOfferModel.fromJson(Map<String, dynamic> json) => JobOfferModel(
        id: json['id'] as int,
        title: json['title'] as String,
        status: _statusFromString(json['status'] as String? ?? 'DRAFT'),
        description: json['description'] as String?,
        location: json['location'] as String?,
        contractType: json['contractType'] as String?,
        deadline: json['deadline'] as String?,
        partnerId: json['partnerId'] as int?,
      );
 
  static JobOfferStatus _statusFromString(String s) => switch (s) {
        'PUBLISHED' => JobOfferStatus.published,
        'CLOSED'    => JobOfferStatus.closed,
        'ARCHIVED'  => JobOfferStatus.archived,
        _           => JobOfferStatus.draft,
      };
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status.name.toUpperCase(),
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (contractType != null) 'contractType': contractType,
        if (deadline != null) 'deadline': deadline,
      };
}