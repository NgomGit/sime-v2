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
    super.residCountryId,
    super.residCountry,
    super.residRegionId,
    super.residRegion,
    super.residDepartmentId,
    super.residDepartment,
    super.residMunicipalityId,
    super.residMunicipality,
    super.nationality,
    required super.address,
    super.branchId,
    super.officeId,
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
      // Les ids résidence/office sont parfois transmis à plat
      // (résidRegionId...), parfois seulement imbriqués dans l'objet
      // complet (résidRegion.id...) selon l'endpoint (voir GET
      // /applicant/api/applicants/me vs. la réponse de login) : on prend le
      // champ à plat s'il existe, sinon on retombe sur l'id de l'objet imbriqué.
      residCountryId: json['residCountryId'] as int? ?? _nestedId(json['residCountry']),
      residCountry: json['residCountry'] != null
          ? CountryModel.fromJson(json['residCountry'] as Map<String, dynamic>) : null,
      residRegionId: json['residRegionId'] as int? ?? _nestedId(json['residRegion']),
      residRegion: json['residRegion'] != null
          ? RegionModel.fromJson(json['residRegion'] as Map<String, dynamic>) : null,
      residDepartmentId: json['residDepartmentId'] as int? ?? _nestedId(json['residDepartment']),
      residDepartment: json['residDepartment'] != null
          ? DepartmentModel.fromJson(json['residDepartment'] as Map<String, dynamic>) : null,
      residMunicipalityId: json['residMunicipalityId'] as int? ?? _nestedId(json['residMunicipality']),
      residMunicipality: json['residMunicipality'] != null
          ? MunicipalityModel.fromJson(json['residMunicipality'] as Map<String, dynamic>) : null,
      nationality: json['nationality'] != null
          ? CountryModel.fromJson(json['nationality'] as Map<String, dynamic>) : null,
      address: json['residAddress']?.toString() ?? 'Non renseignée',
      branchId: json['branchId'] as int?,
      officeId: json['officeId'] as int? ?? _nestedId(json['office']),
      office: json['office'] != null
          ? OfficeModel.fromJson(json['office'] as Map<String, dynamic>) : null,
      userId: json['userId'] as int? ?? 0,
      user: json['userJson'] != null
          ? UserProfileModel.fromJson(json['userJson'] as Map<String, dynamic>) : null,
      cvUrl: json['cvUrl']?.toString(),
      maritalStatus: json['maritalStatus'] != null
          ? ReferenceModel.fromJson(json['maritalStatus'] as Map<String, dynamic>) : null,
      nbChildren: json['nbChildren'] as int?,
      disabilityType: json['disabilityType'] != null
          ? ReferenceModel.fromJson(json['disabilityType'] as Map<String, dynamic>) : null,
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

  /// Extrait l'id d'un objet JSON imbriqué (ex. `residRegion.id`), en toute
  /// sécurité, quel que soit son type réel à l'exécution.
  static int? _nestedId(dynamic node) =>
      node is Map<String, dynamic> ? node['id'] as int? : null;

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

class OfficeModel extends OfficeEntity {
  OfficeModel({
    required super.id,
    super.code,
    required super.name,
    super.phone,
    super.address,
    super.status,
    super.country,
    super.region,
    super.department,
    super.municipality,
    super.antenne,
    super.latitude,
    super.longitude,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    final coords = _parseCoordinate(json['coordinate']);
    return OfficeModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString(),
      name: (json['name'] ?? '').toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      status: json['status'] as bool? ?? true,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>) : null,
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'] as Map<String, dynamic>) : null,
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'] as Map<String, dynamic>) : null,
      municipality: json['municipality'] != null
          ? MunicipalityModel.fromJson(json['municipality'] as Map<String, dynamic>) : null,
      antenne: json['antenne'] != null
          ? ReferenceModel.fromJson(json['antenne'] as Map<String, dynamic>) : null,
      latitude: coords?.$1,
      longitude: coords?.$2,
    );
  }

  /// Parse défensivement le champ `coordinate` — observé à `null` sur tous
  /// les payloads vus jusqu'ici, donc sa forme exacte n'est pas confirmée.
  /// Tente les formes les plus courantes ({lat,lng} / {latitude,longitude} /
  /// GeoJSON Point [lng,lat] / "lat,lng") et retourne `null` si aucune ne
  /// correspond, plutôt que de planter sur un format imprévu.
  static (double, double)? _parseCoordinate(dynamic node) {
    if (node == null) return null;

    double? asDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');

    if (node is Map) {
      final lat = asDouble(node['lat'] ?? node['latitude']);
      final lng = asDouble(node['lng'] ?? node['lon'] ?? node['longitude']);
      if (lat != null && lng != null) return (lat, lng);

      // GeoJSON Point : { type: 'Point', coordinates: [lng, lat] }
      final coordinates = node['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        final lng2 = asDouble(coordinates[0]);
        final lat2 = asDouble(coordinates[1]);
        if (lat2 != null && lng2 != null) return (lat2, lng2);
      }
      return null;
    }

    if (node is List && node.length >= 2) {
      final lng = asDouble(node[0]);
      final lat = asDouble(node[1]);
      if (lat != null && lng != null) return (lat, lng);
      return null;
    }

    if (node is String && node.contains(',')) {
      final parts = node.split(',');
      if (parts.length == 2) {
        final lat = asDouble(parts[0].trim());
        final lng = asDouble(parts[1].trim());
        if (lat != null && lng != null) return (lat, lng);
      }
    }

    return null;
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