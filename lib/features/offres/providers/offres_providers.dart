// features/offres/providers/offres_providers.dart
//
// Injection de dépendances (couche data) pour les offres d'emploi et de
// formation — même grammaire que `besoin_providers.dart`.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';

import '../data/datasources/external_offer_datasource.dart';
import '../data/datasources/job_offer_datasource.dart';
import '../data/datasources/training_offer_datasource.dart';
import '../data/repository/external_offer_repository_impl.dart';
import '../data/repository/job_offer_repository_impl.dart';
import '../data/repository/training_offer_repository_impl.dart';
import '../domain/repositories/external_offer_repository.dart';
import '../domain/repositories/job_offer_repository.dart';
import '../domain/repositories/training_offer_repository.dart';

// ── Offres d'emploi ───────────────────────────────────────────────────────────

final jobOfferRemoteDataSourceProvider =
    Provider<JobOfferRemoteDataSource>((ref) {
  return JobOfferRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final jobOfferRepositoryProvider = Provider<JobOfferRepository>((ref) {
  return JobOfferRepositoryImpl(
    remote: ref.read(jobOfferRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cache: ref.read(hiveCacheProvider),
  );
});

// ── Offres de formation ───────────────────────────────────────────────────────

final trainingOfferRemoteDataSourceProvider =
    Provider<TrainingOfferRemoteDataSource>((ref) {
  return TrainingOfferRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final trainingOfferRepositoryProvider = Provider<TrainingOfferRepository>((ref) {
  return TrainingOfferRepositoryImpl(
    remote: ref.read(trainingOfferRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cache: ref.read(hiveCacheProvider),
  );
});

// ── Offres d'emploi externes (mise en relation) ───────────────────────────────

final externalOfferRemoteDataSourceProvider =
    Provider<ExternalOfferRemoteDataSource>((ref) {
  return ExternalOfferRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final externalOfferRepositoryProvider =
    Provider<ExternalOfferRepository>((ref) {
  return ExternalOfferRepositoryImpl(
    remote: ref.read(externalOfferRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cache: ref.read(hiveCacheProvider),
  );
});
