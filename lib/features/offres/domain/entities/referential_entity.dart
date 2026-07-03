
class CountryEntity {
  const CountryEntity({required this.id, required this.label, this.code});
  final int id;
  final String label;
  final String? code;
}
 
class RegionEntity {
  const RegionEntity({required this.id, required this.label, this.code});
  final int id;
  final String label;
  final String? code;
}
 
class DepartmentEntity {
  const DepartmentEntity({
    required this.id,
    required this.label,
    required this.regionId,
  });
  final int id;
  final String label;
  final int regionId;
}
 
class MunicipalityEntity {
  const MunicipalityEntity({
    required this.id,
    required this.label,
    required this.departmentId,
  });
  final int id;
  final String label;
  final int departmentId;
}
 
class EducationLevelEntity {
  const EducationLevelEntity({required this.id, required this.label});
  final int id;
  final String label;
}
 
class DegreeEntity {
  const DegreeEntity({
    required this.id,
    required this.label,
    this.educationLevelId,
  });
  final int id;
  final String label;
  final int? educationLevelId;
}