// features/profile/data/repositories/applicant_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/core/utils/offline_first_mixin.dart';
import 'package:sime_v2/features/profile/data/datasources/applicant_local_datasource.dart';
import 'package:sime_v2/features/profile/data/datasources/applicant_remote_datasource.dart';
import 'package:sime_v2/features/profile/data/models/applicant_model.dart';
import 'package:sime_v2/features/profile/domain/repositories/applicant_repository.dart';

class ApplicantRepositoryImpl with OfflineFirstMixin implements ApplicantRepository {
  ApplicantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.cache,
  });

  final ApplicantRemoteDataSource remoteDataSource;
  final ApplicantLocalDataSource localDataSource;
  
  @override
  final NetworkInfo networkInfo;
  
  @override
  final HiveCache cache;

  @override
  Future<Either<Failure, ApplicantModel>> getApplicantProfile() async {
    return offlineFirst<ApplicantModel>(
      cacheKey: 'applicant_me_profile',
      remoteCall: () async {
        final rawData = await remoteDataSource.getApplicantProfile();
        final applicant = ApplicantModel.fromJson(rawData);
        // Persistance additionnelle spécifique dans la box locale principale
        await localDataSource.cacheApplicant(applicant);
        return applicant;
      },
      fromCache: (json) => ApplicantModel.fromJson(Map<String, dynamic>.from(json as Map)),
      toJson: (applicant) => applicant.toJson(),
    );
  }

  @override
  Future<Either<Failure, void>> updateApplicantProfile(int id, Map<String, dynamic> fieldsToUpdate) async {
    if (await networkInfo.isConnected) {
      final result = await remoteOnly<void>(() async {
        await remoteDataSource.updateApplicantProfile(id, fieldsToUpdate);
      });

      return result.fold(
        (failure) async {
          // Si l'appel distant échoue malgré la détection réseau, on bascule en stockage local temporel
          await localDataSource.saveOfflineUpdate(id, fieldsToUpdate);
          return const Right(null);
        },
        (success) async {
          await invalidate('applicant_me_profile');
          await getApplicantProfile(); 
          return const Right(null);
        },
      );
    } else {
      // Pas de réseau : File d'attente locale silencieuse
      await localDataSource.saveOfflineUpdate(id, fieldsToUpdate);
      return const Right(null);
    }
  }

  @override
  Future<void> synchronizeOfflineData() async {
    if (!(await networkInfo.isConnected)) return;

    final pending = await localDataSource.getPendingUpdates();
    if (pending.isEmpty) return;

    for (var entry in pending.entries) {
      final id = entry.key;
      final payload = entry.value;

      final result = await remoteOnly<void>(() async {
        await remoteDataSource.updateApplicantProfile(id, payload);
      });

      if (result.isRight()) {
        await localDataSource.clearPendingUpdate(id);
      }
    }
    
    await invalidate('applicant_me_profile');
    await getApplicantProfile();
  }
}

//applicant Repository provider
