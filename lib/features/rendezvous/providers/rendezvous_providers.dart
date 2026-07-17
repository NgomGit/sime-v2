// features/rendezvous/providers/rendezvous_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/features/rendezvous/data/datasources/rdv_datasource.dart';
import 'package:sime_v2/features/rendezvous/data/repositories/rdv_repository_impl.dart';
import 'package:sime_v2/features/rendezvous/domain/repositories/rdv_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. COUCHE DATA - DATASOURCES
// ─────────────────────────────────────────────────────────────────────────────

final rdvRemoteDataSourceProvider = Provider<RdvRemoteDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return RdvRemoteDataSourceImpl(client);
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. COUCHE DOMAIN / DATA - REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────

/// NB : comme pour `applicantRepositoryProvider`, la synchronisation
/// automatique au retour du réseau est déclenchée depuis `RdvNotifier`
/// (features/rendezvous/presentation/providers/rdv_notifier.dart), pas ici.
final rdvRepositoryProvider = Provider<RdvRepository>((ref) {
  return RdvRepositoryImpl(
    remote: ref.read(rdvRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cache: ref.read(hiveCacheProvider),
  );
});
