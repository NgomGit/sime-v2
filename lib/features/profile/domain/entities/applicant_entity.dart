// features/profile/domain/entities/applicant_entity.dart

import 'package:sime_v2/features/auth/domain/entities/reference_entity.dart';

class ApplicantEntity {
  final int id;
  final bool status;
  final String reference;
  final String dateBirth;
  final String? placeBirth;
  final int age;
  final List<dynamic> contacts; // À typer plus tard si nécessaire
  final List<ApplicantIdentityEntity> identities;
  final CountryEntity? residCountry;
  final RegionEntity? residRegion;
  final DepartmentEntity? residDepartment;
  final MunicipalityEntity? residMunicipality;
  final CountryEntity? nationality;
  final String address;
  final int? branchId;
  final dynamic office;
  final int userId;
  final UserProfileEntity? user;
  final String? cvUrl;
  final String? maritalStatus;
  final int? nbChildren;
  final String? disabilityType;
  final ReferenceEntity? educationLevel;
  final ReferenceEntity? lastDegreeObtained;
  final ReferenceEntity? fieldStudy;
  final bool validated;
  final bool hasAdvisor;

  const ApplicantEntity({
    required this.id,
    required this.status,
    required this.reference,
    required this.dateBirth,
    this.placeBirth,
    required this.age,
    required this.contacts,
    required this.identities,
    this.residCountry,
    this.residRegion,
    this.residDepartment,
    this.residMunicipality,
    this.nationality,
    required this.address,
    this.branchId,
    this.office,
    required this.userId,
    this.user,
    this.cvUrl,
    this.maritalStatus,
    this.nbChildren,
    this.disabilityType,
    this.educationLevel,
    this.lastDegreeObtained,
    this.fieldStudy,
    required this.validated,
    required this.hasAdvisor,
  });

  // À ajouter dans ApplicantEntity :
  ApplicantEntity copyWith({
    String? dateBirth,
    CountryEntity? nationality,
    String? address,
    UserProfileEntity? user,
    ReferenceEntity? educationLevel,
    ReferenceEntity? fieldStudy,
    ReferenceEntity? lastDegreeObtained,
    MunicipalityEntity? residMunicipality,
  }) {
    return ApplicantEntity(
      id: id,
      status: status,
      reference: reference,
      dateBirth: dateBirth ?? this.dateBirth,
      placeBirth: placeBirth,
      age: age,
      contacts: contacts,
      identities: identities,
      residCountry: residCountry,
      residRegion: residRegion,
      residDepartment: residDepartment,
      residMunicipality: residMunicipality ?? this.residMunicipality,
      nationality: nationality ?? this.nationality,
      address: address ?? this.address,
      branchId: branchId,
      office: office,
      userId: userId,
      user: user ?? this.user,
      cvUrl: cvUrl,
      maritalStatus: maritalStatus,
      nbChildren: nbChildren,
      disabilityType: disabilityType,
      educationLevel: educationLevel ?? this.educationLevel,
      lastDegreeObtained: lastDegreeObtained ?? this.lastDegreeObtained,
      fieldStudy: fieldStudy ?? this.fieldStudy,
      validated: validated,
      hasAdvisor: hasAdvisor,
    );
  }

  String get fullName {
    if (user == null) return 'Non renseigné';
    final name = '${user!.firstName} ${user!.lastName}'.trim();
    return name.isNotEmpty ? name : 'Non renseigné';
  }

  String get cni {
    if (identities.isEmpty) return 'Non renseigné';

    // On cherche l'élément ou on retourne null si absent
    final doc = identities.cast<ApplicantIdentityEntity?>().firstWhere(
          (d) => d?.isCni ?? false,
          orElse: () => null,
        );

    return doc != null ? doc.value : 'Non renseigné';
  }

  /// Récupère de manière sécurisée la valeur du Passeport
  String get passport {
    if (identities.isEmpty) return 'Non renseigné';

    final doc = identities.cast<ApplicantIdentityEntity?>().firstWhere(
          (d) => d?.isPassport ?? false,
          orElse: () => null,
        );

    return doc != null ? doc.value : 'Non renseigné';
  }
}

/// Sous-entité pour la gestion des pièces d'identité
class ApplicantIdentityEntity {
  final int id;
  final bool status;
  final String type;
  final String value;
  final List<String> fileUrls;

  const ApplicantIdentityEntity({
    required this.id,
    required this.status,
    required this.type,
    required this.value,
    required this.fileUrls,
  });

  /// Permet d'identifier rapidement si le document est une CNI
  bool get isCni => type.toUpperCase() == 'CNI';

  /// Permet d'identifier rapidement si le document est un Passeport
  bool get isPassport => type.toUpperCase() == 'PASSPORT';
}

/// Sous-entité générique pour les données géographiques (Country, Region, Department)
class LocationEntity {
  final int id;
  final String code;
  final String name;
  final bool status;

  const LocationEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
  });
}

/// Sous-entité pour le compte utilisateur lié
class UserProfileEntity {
  final int id;
  final String sex;
  final String email;
  final String phone;
  final String username;
  final String firstName;
  final String lastName;
  final bool active;

  const UserProfileEntity({
    required this.id,
    required this.sex,
    required this.email,
    required this.phone,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.active,
  });

  // À ajouter dans UserProfileEntity :
  UserProfileEntity copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
  }) {
    return UserProfileEntity(
      id: id,
      sex: sex,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      active: active,
    );
  }
}
