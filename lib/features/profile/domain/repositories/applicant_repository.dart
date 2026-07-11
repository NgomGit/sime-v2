// features/profile/domain/repositories/applicant_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/profile/data/models/applicant_model.dart';

abstract class ApplicantRepository {
  /// Récupère le profil sous forme de Either (Offline-first automatique)
  Future<Either<Failure, ApplicantModel>> getApplicantProfile();

  /// Met à jour les informations du demandeur
  Future<Either<Failure, void>> updateApplicantProfile(int id, Map<String, dynamic> fieldsToUpdate);

  /// Synchronise en tâche de fond les modifications stockées dans la file d'attente Hive
  Future<void> synchronizeOfflineData();
}