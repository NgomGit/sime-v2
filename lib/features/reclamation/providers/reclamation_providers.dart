// features/reclamation/providers/reclamation_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';

import '../data/datasources/reclamation_local_datasource.dart';
import '../data/datasources/reclamation_remote_datasource.dart';
import '../data/repositories/reclamation_repository_impl.dart';
import '../domain/repositories/reclamation_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. COUCHE DATA - DATASOURCES
// ─────────────────────────────────────────────────────────────────────────────

final reclamationRemoteDataSourceProvider =
    Provider<ReclamationRemoteDataSource>((ref) {
  return ReclamationRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final reclamationLocalDataSourceProvider =
    Provider<ReclamationLocalDataSource>((ref) {
  return ReclamationLocalDataSourceImpl();
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. COUCHE DOMAIN / DATA - REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────

/// NB : la synchronisation automatique au retour du réseau est déclenchée
/// depuis `reclamationsNotifierProvider` (et non ici), pour que l'UI reflète
/// l'état via `ReclamationsState.isSyncing` — même choix que rdv/applicant.
final reclamationRepositoryProvider = Provider<ReclamationRepository>((ref) {
  return ReclamationRepositoryImpl(
    remote: ref.read(reclamationRemoteDataSourceProvider),
    local: ref.read(reclamationLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cache: ref.read(hiveCacheProvider),
  );
});
