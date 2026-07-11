// features/profile/domain/entities/reference_entities.dart

class ReferenceEntity {
  final int id;
  final String name;
  final String? code;
  final String? status;

  const ReferenceEntity({
    required this.id,
    required this.name,
    this.code,
    this.status,
  });
}

class CountryEntity {
  final int id;
  final String code;
  final String alpha2;
  final String name;

  const CountryEntity({
    required this.id,
    required this.code,
    required this.alpha2,
    required this.name,
  });
}

class RegionEntity {
  final int id;
  final String code;
  final String name;
  final bool status;
  final CountryEntity? country;

  const RegionEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    this.country,
  });
}

class DepartmentEntity {
  final int id;
  final String code;
  final String name;
  final RegionEntity? region;

  const DepartmentEntity({
    required this.id,
    required this.code,
    required this.name,
    this.region,
  });
}

class MunicipalityEntity {
  final int id;
  final String code;
  final String name;
  final bool status;
  final DepartmentEntity? department;

  const MunicipalityEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    this.department,
  });
}