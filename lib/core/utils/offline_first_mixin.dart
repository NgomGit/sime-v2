import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../error/failures.dart';
import '../network/network_info.dart';
import '../storage/hive_cache.dart';

/// Mixin offline-first pour tous les repositories SIME v2.
///
/// Utilise :
///   • [dartz] → Either<Failure, T> natif du projet
///   • [hive]  → cache local JSON (box 'sime_cache')
///   • [dio]   → mapping des erreurs HTTP → Failure
///
/// ─── Pattern appliqué ────────────────────────────────────────────────────────
///
///  offlineFirst (lectures) :
///    1. Connecté  → appel API → sérialise en JSON → Hive.put → Right(data)
///    2. Hors ligne → Hive.get → désérialise → Right(data)
///    3. Hors ligne + cache absent → Left(CacheFailure)
///
///  remoteOnly (mutations POST / PUT / PATCH / DELETE) :
///    1. Connecté  → appel API → Right(data)
///    2. Hors ligne → Left(NetworkFailure) immédiat
///
/// ─── Prérequis ───────────────────────────────────────────────────────────────
///
/// Le repository concret doit exposer :
///   ```dart
///   @override NetworkInfo get networkInfo;
///   @override HiveCache   get cache;
///   ```
mixin OfflineFirstMixin {
  NetworkInfo get networkInfo;
  HiveCache   get cache;

  // ── Lecture offline-first ─────────────────────────────────────────────────

  /// Charge [T] depuis l'API si connecté, sinon depuis le cache Hive.
  ///
  /// [cacheKey]   : clé Hive — utiliser les constantes [HiveCacheKeys].
  /// [remoteCall] : appel datasource distant qui retourne [T].
  /// [fromCache]  : désérialiseur JSON → [T] (appelé si hors ligne).
  /// [toJson]     : sérialiseur [T] → JSON (optionnel — utilisé si [T] n'est
  ///                pas nativement une List/Map, ex. objet avec `.toJson()`).
  Future<Either<Failure, T>> offlineFirst<T>({
    required String cacheKey,
    required Future<T> Function() remoteCall,
    required T Function(dynamic json) fromCache,
    dynamic Function(T data)? toJson,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final data = await remoteCall();
        // Persister en cache Hive pour usage offline ultérieur
        final jsonValue = toJson != null ? toJson(data) : _autoSerialize(data);
        await cache.put(cacheKey, jsonValue);
        return Right(data);
      } on DioException catch (e) {
        // En cas d'erreur réseau malgré la connexion : tenter le cache
        final cached = cache.get(cacheKey);
        if (cached != null) {
          try {
            return Right(fromCache(cached));
          } catch (_) { /* cache corrompu → remonter l'erreur Dio */ }
        }
        return Left(_mapDioError(e));
      } catch (e) {
        return Left(UnknownFailure(e.toString(), message: 'Erreur inconnue'));
      }
    } else {
      // Mode offline → lecture Hive
      final cached = cache.get(cacheKey);
      if (cached == null) {
        return const Left(CacheFailure(message: 'Aucune donnée en cache'));
      }
      try {
        return Right(fromCache(cached));
      } catch (_) {
        return const Left(CacheFailure(message: 'Données en cache corrompues'));
      }
    }
  }

  // ── Mutation réseau uniquement ─────────────────────────────────────────────

  /// Exécute [remoteCall] uniquement si connecté.
  /// Retourne [NetworkFailure] immédiatement si hors ligne.
  ///
  /// Après une mutation réussie, invalider le cache concerné via
  /// `cache.delete(HiveCacheKeys.xxx)` dans le repository.
  Future<Either<Failure, T>> remoteOnly<T>(
    Future<T> Function() remoteCall,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Vous êtes hors ligne'));
    }
    try {
      return Right(await remoteCall());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString(), message: 'Erreur inconnue'));
    }
  }

  // ── Invalidation cache ────────────────────────────────────────────────────

  /// Supprime une entrée du cache (ex. après une mutation réussie).
  Future<void> invalidate(String cacheKey) => cache.delete(cacheKey);

  /// Supprime plusieurs entrées (ex. après logout).
  Future<void> invalidateAll(List<String> keys) async {
    for (final key in keys) {
      await cache.delete(key);
    }
  }

  // ── Mapping erreurs Dio → Failure ─────────────────────────────────────────

  Failure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final serverMessage =
        e.response?.data is Map<String, dynamic>
            ? (e.response!.data as Map<String, dynamic>)['message']
                ?.toString()
            : null;

    if (statusCode != null) {
      return switch (statusCode) {
        400 => ValidationFailure( message: serverMessage ?? 'Données invalides'),
        401 => const AuthFailure(message: 'Non autorisé'),
        403 => const AuthFailure(message: 'Accès refusé'),
        404 => const NotFoundFailure(message: 'Resource non trouvée'),
        >= 500 => ServerFailure( message: serverMessage ?? 'Erreur serveur'),
        _ => const UnknownFailure('', message: 'Erreur inconnue'),
      };
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout    ||
      DioExceptionType.sendTimeout       =>
          const NetworkFailure(message: 'Délai de connexion dépassé'),
      DioExceptionType.connectionError   =>
          const NetworkFailure(message: 'Impossible de joindre le serveur'),
      DioExceptionType.cancel            =>
          const UnknownFailure('Requête annulée', message: 'Requête annulée'),
      _                                  => const NetworkFailure(message: 'Erreur de réseau'),
    };
  }

  // ── Sérialisation automatique ─────────────────────────────────────────────

  /// Tente de sérialiser [data] en JSON.
  /// Supporte : List, Map, et tout objet exposant `.toJson()`.
  dynamic _autoSerialize(dynamic data) {
    if (data is List || data is Map) return data;
    try {
      // ignore: avoid_dynamic_calls
      return (data as dynamic).toJson();
    } catch (_) {
      throw ArgumentError(
        '[OfflineFirstMixin] Impossible de sérialiser ${data.runtimeType}. '
        'Fournissez un paramètre `toJson` explicite.',
      );
    }
  }
}