

// Ajout du provider pour la gestion des référentiels (/param/api)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sime_v2/features/auth/data/datasources/reference_remote_datasource.dart';
import 'package:sime_v2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sime_v2/features/auth/domain/usecases/register_demandeur.dart';

final referenceDataSourceProvider = Provider((ref) => ReferenceRemoteDataSource(ref.read(apiClientProvider)));

final authRemoteDataSourceProvider =
    Provider((ref) => AuthRemoteDataSource(ref.read(apiClientProvider)));
    
final authRepositoryProvider = Provider(
    (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)));

final registerDemandeurUseCaseProvider = Provider(
    (ref) => RegisterDemandeurUseCase(ref.read(authRepositoryProvider)));
