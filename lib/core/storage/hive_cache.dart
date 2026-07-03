import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Nom de la box Hive utilisée pour tout le cache applicatif SIME v2.
const _kCacheBox = 'sime_cache';

/// Clés de cache Hive — une constante par ressource pour éviter les fautes
/// de frappe et centraliser les invalidations.
abstract final class HiveCacheKeys {
  static const applicantMe      = 'applicant_me';
  static const subscriptionsMe  = 'subscriptions_me';
  static const rdvsMe           = 'rdvs_me';
  static const jobOffers        = 'job_offers';
  static const services         = 'services';
  static const servicesForMe    = 'services_for_me';
  static const countries        = 'countries';
  static const regions          = 'regions';
  static const educationLevels  = 'education_levels';
  static const degrees          = 'degrees';

  /// Clés paramétrées — inclure l'ID dans la clé pour un cache par entité.
  static String departments(int regionId)     => 'departments_$regionId';
  static String municipalities(int deptId)    => 'municipalities_$deptId';
}

/// Service de cache local basé sur Hive.
///
/// Stocke des chaînes JSON encodées dans une box ouverte au démarrage.
/// Toutes les méthodes sont synchrones côté lecture (Hive lazy-box excepté)
/// pour une récupération offline instantanée.
///
/// Initialisation dans `main.dart` :
/// ```dart
/// await HiveCache.init();
/// runApp(ProviderScope(
///   overrides: [hiveCacheProvider.overrideWithValue(HiveCache())],
///   child: const SimeApp(),
/// ));
/// ```
class HiveCache {
  HiveCache(this._box);

  final Box<String> _box;

  /// Ouvrir la box avant `runApp`.
  static Future<HiveCache> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(_kCacheBox);
    return HiveCache(box);
  }

  // ── Écriture ──────────────────────────────────────────────────────────────

  Future<void> put(String key, dynamic value) async {
    await _box.put(key, jsonEncode(value));
  }

  // ── Lecture ───────────────────────────────────────────────────────────────

  /// Retourne la valeur désérialisée ou `null` si absente / corrompue.
  dynamic get(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  // ── Suppression ───────────────────────────────────────────────────────────

  Future<void> delete(String key)  => _box.delete(key);
  Future<void> clearAll()          => _box.clear();

  // ── Introspection ─────────────────────────────────────────────────────────

  bool containsKey(String key) => _box.containsKey(key);
}

// ── Provider ─────────────────────────────────────────────────────────────────

/// À surcharger dans le `ProviderScope` après `HiveCache.init()`.
final hiveCacheProvider = Provider<HiveCache>(
  (_) => throw UnimplementedError(
    'Initialise HiveCache avant runApp et surcharge hiveCacheProvider.',
  ),
);