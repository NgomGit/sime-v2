
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/offres/domain/entities/referential_entity.dart';

abstract interface class ReferentielRepository {
  Future<Either<Failure, List<CountryEntity>>> getCountries();
  Future<Either<Failure, List<RegionEntity>>> getRegions();
  Future<Either<Failure, List<DepartmentEntity>>> getDepartments(int regionId);
  Future<Either<Failure, List<MunicipalityEntity>>> getMunicipalities(
    int departmentId,
  );
  Future<Either<Failure, List<EducationLevelEntity>>> getEducationLevels();
  Future<Either<Failure, List<DegreeEntity>>> getDegrees();
}