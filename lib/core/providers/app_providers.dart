 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/features/auth/data/datasources/applicant_remote_datasource.dart';
import 'package:sime_v2/features/auth/data/datasources/subscription_datasource.dart';
import 'package:sime_v2/features/auth/data/repositories/applicant_repository_impl.dart';
import 'package:sime_v2/features/auth/data/repositories/subscription_repository_impl.dart';
import 'package:sime_v2/features/offres/data/datasources/anpej_service_datasource.dart';
import 'package:sime_v2/features/offres/data/datasources/job_offer_datasource.dart';
import 'package:sime_v2/features/offres/data/datasources/referential_datasource.dart';
import 'package:sime_v2/features/offres/data/repository/anpej_repository_impl.dart';
import 'package:sime_v2/features/offres/data/repository/job_offer_repository_impl.dart';
import 'package:sime_v2/features/offres/data/repository/referential_repository.dart';
import 'package:sime_v2/features/rendezvous/data/datasources/rdv_datasource.dart';
import 'package:sime_v2/features/rendezvous/data/repositories/rdv_repository_impl.dart';

final applicantRemoteDsProvider = Provider<ApplicantRemoteDataSource>(
  (ref) => ApplicantRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
final applicantRepoProvider = Provider(
  (ref) => ApplicantRepositoryImpl(
    remote: ref.watch(applicantRemoteDsProvider),
    networkInfo: ref.watch(networkInfoProvider),
    cache: ref.watch(hiveCacheProvider),
  ),
);
 
final subscriptionRemoteDsProvider = Provider<SubscriptionRemoteDataSource>(
  (ref) => SubscriptionRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
final subscriptionRepoProvider = Provider(
  (ref) => SubscriptionRepositoryImpl(
    remote: ref.watch(subscriptionRemoteDsProvider),
    networkInfo: ref.watch(networkInfoProvider),
    cache: ref.watch(hiveCacheProvider),
  ),
);
 
final jobOfferRemoteDsProvider = Provider<JobOfferRemoteDataSource>(
  (ref) => JobOfferRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
final jobOfferRepoProvider = Provider(
  (ref) => JobOfferRepositoryImpl(
    remote: ref.watch(jobOfferRemoteDsProvider),
    networkInfo: ref.watch(networkInfoProvider),
    cache: ref.watch(hiveCacheProvider),
  ),
);
 
final rdvRemoteDsProvider = Provider<RdvRemoteDataSource>(
  (ref) => RdvRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
final rdvRepoProvider = Provider(
  (ref) => RdvRepositoryImpl(
    remote: ref.watch(rdvRemoteDsProvider),
    networkInfo: ref.watch(networkInfoProvider),
    cache: ref.watch(hiveCacheProvider),
  ),
);
 
final anpejServiceRemoteDsProvider = Provider<AnpejServiceRemoteDataSource>(
  (ref) => AnpejServiceRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
final anpejServiceRepoProvider = Provider(
  (ref) => AnpejServiceRepositoryImpl(
    remote: ref.watch(anpejServiceRemoteDsProvider),
    networkInfo: ref.watch(networkInfoProvider),
    cache: ref.watch(hiveCacheProvider),
  ),
);
 
final referentielRemoteDsProvider = Provider<ReferentielRemoteDataSource>(
  (ref) => ReferentielRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
final referentielRepoProvider = Provider(
  (ref) => ReferentielRepositoryImpl(
    remote: ref.watch(referentielRemoteDsProvider),
    networkInfo: ref.watch(networkInfoProvider),
    cache: ref.watch(hiveCacheProvider),
  ),
);