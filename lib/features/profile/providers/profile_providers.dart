import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/api_client.dart'; // Ajuste selon ton projet
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';

// Import DataSources
import 'package:sime_v2/features/profile/data/datasources/applicant_local_datasource.dart';
import 'package:sime_v2/features/profile/data/datasources/applicant_remote_datasource.dart';

// Import Repositories
import 'package:sime_v2/features/profile/data/repositories/applicant_repository_impl.dart';
import 'package:sime_v2/features/profile/domain/repositories/applicant_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. COUCHE DATA - DATASOURCES
// ─────────────────────────────────────────────────────────────────────────────

/// Provider pour la source de données distante (Créé ici !)
final applicantRemoteDataSourceProvider = Provider<ApplicantRemoteDataSource>((ref) {
  final client = ref.read(apiClientProvider); // Utilise ton instance Dio / ApiClient globale
  return ApplicantRemoteDataSourceImpl(apiClient: client);
});

/// Provider pour la source de données locale
final applicantLocalDataSourceProvider = Provider<ApplicantLocalDataSource>((ref) {
  return ApplicantLocalDataSourceImpl();
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. COUCHE DOMAIN / DATA - REPOSITORIES
// ─────────────────────────────────────────────────────────────────────────────

/// Provider du Répertoire lié au contrat abstrait du Domain
final applicantRepositoryProvider = Provider<ApplicantRepository>((ref) {
  final repository = ApplicantRepositoryImpl(
    remoteDataSource: ref.read(applicantRemoteDataSourceProvider),
    localDataSource: ref.read(applicantLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cache: ref.read(hiveCacheProvider),
  );

  // Écouteur réactif pour la synchronisation automatique dès le retour du réseau
  ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) {
    if (next.value == true) {
      repository.synchronizeOfflineData();
    }
  });

  return repository;
});
