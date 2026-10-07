import 'dart:convert';

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
        return const Left(UnknownFailure(message: 'Erreur inconnue'));
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
      return const Left(UnknownFailure( message: 'Erreur inconnue'));
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
    final serverMessage = _extractServerMessage(e.response?.data);

    if (statusCode != null) {
      return switch (statusCode) {
        400 => ValidationFailure( message: serverMessage ?? 'Données invalides'),
        401 => const AuthFailure(message: 'Non autorisé'),
        403 => const AuthFailure(message: 'Accès refusé'),
        404 => const NotFoundFailure(message: 'Resource non trouvée'),
        >= 500 => ServerFailure( message: serverMessage ?? 'Erreur serveur'),
        _ => const UnknownFailure(message: 'Erreur inconnue'),
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
          const UnknownFailure(message: 'Requête annulée'),
      _                                  => const NetworkFailure(message: 'Erreur de réseau'),
    };
  }

  // ── Extraction du message d'erreur backend ────────────────────────────────
  //
  // Le Gateway enveloppe souvent l'erreur du micro-service en aval : le
  // `message` de premier niveau est générique (« Error occurred ») et le vrai
  // message métier se trouve dans `debugMessage`, sous la forme
  // `400 : "{...json...}"`. On plonge donc dans cette structure imbriquée pour
  // remonter le message le plus utile à afficher à l'utilisateur.

  /// Messages génériques du Gateway à ignorer au profit du message métier réel.
  static const _genericMessages = {
    '', 'error occurred', 'erreur', 'bad_request', 'internal_server_error',
    'not_found', 'unauthorized', 'forbidden',
  };

  bool _isGeneric(String s) => _genericMessages.contains(s.trim().toLowerCase());

  /// Décode un éventuel JSON imbriqué dans une chaîne (ex. le contenu de
  /// `debugMessage` : `400 : "{...}"`), en isolant le premier objet `{...}`.
  Map<String, dynamic>? _tryDecodeEmbeddedJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end <= start) return null;
    try {
      final decoded = jsonDecode(raw.substring(start, end + 1));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Retire un préfixe de statut (`400 : `) et les guillemets englobants.
  String _stripStatusPrefix(String s) {
    var out = s.replaceFirst(RegExp(r'^\s*\d{3}\s*:\s*'), '').trim();
    if (out.length >= 2 && out.startsWith('"') && out.endsWith('"')) {
      out = out.substring(1, out.length - 1);
    }
    return out.trim();
  }

  /// Remonte le message backend le plus pertinent depuis [data], en explorant
  /// récursivement `debugMessage` (qui peut contenir un JSON imbriqué).
  String? _extractServerMessage(dynamic data) {
    if (data == null) return null;

    Map<String, dynamic>? map;
    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is String) {
      map = _tryDecodeEmbeddedJson(data);
      if (map == null) {
        final s = _stripStatusPrefix(data);
        return (s.isEmpty || _isGeneric(s)) ? null : s;
      }
    } else {
      return null;
    }

    final msg = map['message']?.toString();
    final debug = map['debugMessage']?.toString();

    // 1. Priorité au message profond caché dans un debugMessage imbriqué.
    if (debug != null) {
      final embedded = _tryDecodeEmbeddedJson(debug);
      if (embedded != null) {
        final deeper = _extractServerMessage(embedded);
        if (deeper != null && !_isGeneric(deeper)) return deeper;
      }
    }

    // 2. Sinon le message de ce niveau, s'il est réellement informatif.
    if (msg != null && !_isGeneric(msg)) return msg.trim();

    // 3. Sinon un debugMessage en clair (préfixe de statut retiré).
    if (debug != null) {
      final stripped = _stripStatusPrefix(debug);
      if (stripped.isNotEmpty && !_isGeneric(stripped)) return stripped;
    }

    // 4. En dernier recours, le message générique (mieux que rien).
    return (msg != null && msg.trim().isNotEmpty) ? msg.trim() : null;
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