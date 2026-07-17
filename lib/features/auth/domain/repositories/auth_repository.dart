// features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/domain/entities/registration_entity.dart';
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';


abstract class AuthRepository {
  Future<void> registerFullDemandeur(RegistrationEntity entity);
  Future<AuthResponseModel> login(String username, String password);

  /// PUT /auth/api/auth/me — l'API renvoie la ressource "compte utilisateur"
  /// (id, firstName, lastName, sex, username, email, phone, active, roles...),
  /// PAS le dossier candidat complet. D'où le retour en [UserProfileEntity]
  /// et non [ApplicantEntity] (voir ApplicantNotifier.updateUserAccountFields
  /// qui fusionne ce résultat dans l'applicant courant).
  Future<Either<Failure, UserProfileEntity>> updateUserAccount(Map<String, dynamic> payload);
}