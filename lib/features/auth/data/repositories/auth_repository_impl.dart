// features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/domain/entities/registration_entity.dart';
import 'package:sime_v2/features/profile/data/models/applicant_model.dart';
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';

import '../../domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> registerFullDemandeur(RegistrationEntity entity) async {
    // // Phase 1: Create base system credential access
    // await _remoteDataSource.registerUserAccount(entity);
    
    // Phase 1 et 2: Create profile folder record binding context
    await _remoteDataSource.registerApplicantProfile(entity);
  }
  
  @override
  Future<AuthResponseModel> login(String username, String password) async {
    final responseModel = await _remoteDataSource.login(
      username: username,
      password: password,
    );

    // 1. Sauvegarde du jeton de sécurité de manière persistante
    // await _secureStorageService.writeToken(responseModel.token);

    // 2. Retour de l'entité domaine mappée pour le Notifier
    return responseModel;
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserAccount(Map<String, dynamic> payload) async {
    final json = await _remoteDataSource.updateAuthUser(payload);
    // La réponse de PUT /auth/api/auth/me est la ressource "compte
    // utilisateur" (id, firstName, lastName, sex, username, email, phone,
    // active...), pas un ApplicantModel complet : on la parse en
    // UserProfileModel, dont les champs correspondent exactement.
    return Right(UserProfileModel.fromJson(json));
  }
  
}
