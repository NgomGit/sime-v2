// features/besoin/providers/besoin_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';

import '../data/datasources/besoin_remote_datasource.dart';
import '../data/repositories/besoin_repository_impl.dart';
import '../domain/repositories/besoin_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. COUCHE DATA — DATASOURCE
// ─────────────────────────────────────────────────────────────────────────────

final besoinRemoteDataSourceProvider = Provider<BesoinRemoteDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return BesoinRemoteDataSourceImpl(client);
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. COUCHE DOMAIN / DATA — REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────

final besoinRepositoryProvider = Provider<BesoinRepository>((ref) {
  return BesoinRepositoryImpl(
    remote: ref.read(besoinRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cache: ref.read(hiveCacheProvider),
  );
});
