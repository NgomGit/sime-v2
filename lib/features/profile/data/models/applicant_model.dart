// features/profile/data/models/applicant_model.dart
import 'package:sime_v2/features/auth/data/models/reference_model.dart';
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';

class ApplicantModel extends ApplicantEntity {
  final Map<String, dynamic> rawJson;

  ApplicantModel({
    required super.id,
    required super.status,
    required super.reference,
    required super.dateBirth,
    super.placeBirth,
    required super.age,
    required super.contacts,
    required super.identities,
    super.residCountry,
    super.residRegion,
    super.residDepartment,
    super.residMunicipality,
    super.nationality,
    required super.address,
    super.branchId,
    super.office,
    required super.userId,
    super.user,
    super.cvUrl,
    super.maritalStatus,
    super.nbChildren,
    super.disabilityType,
    super.educationLevel,
    super.lastDegreeObtained,
    super.fieldStudy,
    required super.validated,
    required super.hasAdvisor,
    required this.rawJson,
  });

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    return ApplicantModel(
      id: json['id'] as int,
      status: json['status'] as bool? ?? false,
      reference: json['reference']?.toString() ?? '',
      dateBirth: json['dateBirth']?.toString() ?? '',
      placeBirth: json['placeBirth']?.toString(),
      age: json['age'] as int? ?? 0,
      contacts: json['contacts'] as List<dynamic>? ?? [],
      identities: (json['identities'] as List<dynamic>?)
              ?.map((e) => ApplicantIdentityModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      residCountry: json['residCountry'] != null 
          ? CountryModel.fromJson(json['residCountry'] as Map<String, dynamic>) : null,
      residRegion: json['residRegion'] != null 
          ? RegionModel.fromJson(json['residRegion'] as Map<String, dynamic>) : null,
      residDepartment: json['residDepartment'] != null 
          ? DepartmentModel.fromJson(json['residDepartment'] as Map<String, dynamic>) : null,
      residMunicipality: json['residMunicipality'] != null 
          ? MunicipalityModel.fromJson(json['residMunicipality'] as Map<String, dynamic>) : null,
      nationality: json['nationality'] != null 
          ? CountryModel.fromJson(json['nationality'] as Map<String, dynamic>) : null,
      address: json['residAddress']?.toString() ?? 'Non renseignée',
      branchId: json['branchId'] as int?,
      office: json['office'],
      userId: json['userId'] as int? ?? 0,
      user: json['userJson'] != null 
          ? UserProfileModel.fromJson(json['userJson'] as Map<String, dynamic>) : null,
      cvUrl: json['cvUrl']?.toString(),
      maritalStatus: json['maritalStatus']?.toString(),
      nbChildren: json['nbChildren'] as int?,
      disabilityType: json['disabilityType']?.toString(),
      educationLevel: json['educationLevel'] != null 
          ? ReferenceModel.fromJson(json['educationLevel'] as Map<String, dynamic>) : null,
      lastDegreeObtained: json['lastDegreeObtained'] != null 
          ? ReferenceModel.fromJson(json['lastDegreeObtained'] as Map<String, dynamic>) : null,
      fieldStudy: json['fieldStudy'] != null 
          ? ReferenceModel.fromJson(json['fieldStudy'] as Map<String, dynamic>) : null,
      validated: json['validated'] as bool? ?? false,
      hasAdvisor: json['hasAdvisor'] as bool? ?? false,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}

// ── MODÈLES DE SÉRIALISATION INTERNES ──

class ApplicantIdentityModel extends ApplicantIdentityEntity {
  ApplicantIdentityModel({required super.id, required super.status, required super.type, required super.value, required super.fileUrls});

  factory ApplicantIdentityModel.fromJson(Map<String, dynamic> json) {
    return ApplicantIdentityModel(
      id: json['id'] as int,
      status: json['status'] as bool? ?? false,
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      fileUrls: (json['fileUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class LocationModel extends LocationEntity {
  LocationModel({required super.id, required super.code, required super.name, required super.status});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status'] as bool? ?? false,
    );
  }
}

class UserProfileModel extends UserProfileEntity {
  UserProfileModel({required super.id, required super.sex, required super.email, required super.phone, required super.username, required super.firstName, required super.lastName, required super.active});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      sex: json['sex']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      active: json['active'] as bool? ?? false,
    );
  }
}