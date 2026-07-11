// features/profile/data/models/reference_models.dart

import 'package:sime_v2/features/auth/domain/entities/reference_entity.dart';

class ReferenceModel extends ReferenceEntity {
  const ReferenceModel({
    required super.id,
    required super.name,
    super.code,
    super.status,
  });

  factory ReferenceModel.fromJson(Map<String, dynamic> json) {
    return ReferenceModel(
      id: json['id'] as int? ?? 0,
      name: (json['name'] ?? json['libelle'] ?? json['nameFr'] ?? '').toString(),
      code: (json['code'] ?? json['iso3'] ?? json['codeAlpha2'])?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
    };
  }
}

class CountryModel extends CountryEntity {
  const CountryModel({
    required super.id,
    required super.code,
    required super.alpha2,
    required super.name,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      alpha2: json['alpha2'] ?? json['alpha2']?.toString() ?? '',
      name: (json['name'] ?? json['libelle'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'alpha2': alpha2,
      'name': name,
    };
  }
}

class RegionModel extends RegionEntity {
  const RegionModel({
    required super.id,
    required super.code,
    required super.name,
    required super.status,
    super.country,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      name: (json['name'] ?? json['libelle'] ?? '').toString(),
      status: json['status'] as bool? ?? false,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      if (country != null) 'country': (country as CountryModel).toJson(),
    };
  }
}

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.code,
    required super.name,
    super.region,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      name: (json['name'] ?? json['libelle'] ?? '').toString(),
      region: json['region'] != null 
          ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (region != null) 'region': (region as RegionModel).toJson(),
    };
  }
}

class MunicipalityModel extends MunicipalityEntity {
  const MunicipalityModel({
    required super.id,
    required super.code,
    required super.name,
    required super.status,
    super.department,
  });

  factory MunicipalityModel.fromJson(Map<String, dynamic> json) {
    return MunicipalityModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      name: (json['name'] ?? json['libelle'] ?? '').toString(),
      status: json['status'] as bool? ?? false,
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      if (department != null) 'department': (department as DepartmentModel).toJson(),
    };
  }
}