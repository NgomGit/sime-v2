
import 'package:sime_v2/features/auth/domain/entities/applicant_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({required super.type, required super.value});
 
  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        type: json['type'] as String,
        value: json['value'] as String,
      );
 
  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}
 
class ApplicantModel extends ApplicantEntity {
  const ApplicantModel({
    required super.id,
    required super.reference,
    required super.validated,
    super.dateBirth,
    super.placeBirth,
    super.residAddress,
    super.hasAdvisor,
    super.contacts,
  });
 
  factory ApplicantModel.fromJson(Map<String, dynamic> json) => ApplicantModel(
        id: json['id'] as int,
        reference: json['reference'] as String? ?? '',
        validated: json['validated'] as bool? ?? false,
        dateBirth: json['dateBirth'] as String?,
        placeBirth: json['placeBirth'] as String?,
        residAddress: json['residAddress'] as String?,
        hasAdvisor: json['hasAdvisor'] as bool? ?? false,
        contacts: (json['contacts'] as List<dynamic>?)
                ?.map((e) =>
                    ContactModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'validated': validated,
        if (dateBirth != null) 'dateBirth': dateBirth,
        if (placeBirth != null) 'placeBirth': placeBirth,
        if (residAddress != null) 'residAddress': residAddress,
        'hasAdvisor': hasAdvisor,
        'contacts': contacts
            .map((c) => (c as ContactModel).toJson())
            .toList(),
      };
}
 