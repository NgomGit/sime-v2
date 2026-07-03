
import 'package:sime_v2/features/offres/domain/entities/referential_entity.dart';

class CountryModel extends CountryEntity {
  const CountryModel({required super.id, required super.label, super.code});
 
  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id'] as int,
        label: json['label'] as String,
        code: json['code'] as String?,
      );
 
  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'code': code};
}
 
class RegionModel extends RegionEntity {
  const RegionModel({required super.id, required super.label, super.code});
 
  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
        id: json['id'] as int,
        label: json['label'] as String,
        code: json['code'] as String?,
      );
 
  Map<String, dynamic> toJson() => {'id': id, 'label': label};
}
 
class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.label,
    required super.regionId,
  });
 
  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        id: json['id'] as int,
        label: json['label'] as String,
        regionId: json['regionId'] as int,
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'regionId': regionId,
      };
}
 
class MunicipalityModel extends MunicipalityEntity {
  const MunicipalityModel({
    required super.id,
    required super.label,
    required super.departmentId,
  });
 
  factory MunicipalityModel.fromJson(Map<String, dynamic> json) =>
      MunicipalityModel(
        id: json['id'] as int,
        label: json['label'] as String,
        departmentId: json['departmentId'] as int,
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'departmentId': departmentId,
      };
}
 
class EducationLevelModel extends EducationLevelEntity {
  const EducationLevelModel({required super.id, required super.label});
 
  factory EducationLevelModel.fromJson(Map<String, dynamic> json) =>
      EducationLevelModel(
        id: json['id'] as int,
        label: json['label'] as String,
      );
 
  Map<String, dynamic> toJson() => {'id': id, 'label': label};
}
 
class DegreeModel extends DegreeEntity {
  const DegreeModel({
    required super.id,
    required super.label,
    super.educationLevelId,
  });
 
  factory DegreeModel.fromJson(Map<String, dynamic> json) => DegreeModel(
        id: json['id'] as int,
        label: json['label'] as String,
        educationLevelId: json['educationLevelId'] as int?,
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        if (educationLevelId != null) 'educationLevelId': educationLevelId,
      };
}