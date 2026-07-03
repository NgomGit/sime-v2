import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/auth/domain/entities/applicant_entity.dart';

abstract interface class ApplicantRepository {
  /// GET /api/applicants/me
  Future<Either<Failure, ApplicantEntity>> getMyProfile();
 
  /// POST /api/applicants/register
  Future<Either<Failure, ApplicantEntity>> registerApplicant(
    Map<String, dynamic> body,
  );
 
  /// PUT /api/applicants/me
  Future<Either<Failure, ApplicantEntity>> updateMyProfile(
    Map<String, dynamic> body,
  );
}