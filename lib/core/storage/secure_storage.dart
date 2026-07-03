import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clés de stockage sécurisé
abstract final class _SecureKeys {
  static const accessToken  = 'sime_access_token';
  static const username     = 'sime_username';
  static const password     = 'sime_password';
}

/// Clés de cache local (SharedPreferences)
abstract final class _CacheKeys {
  static const prefix         = 'sime_cache_';
  static const applicantMe    = '${prefix}applicant_me';
  static const subscriptionsMe = '${prefix}subscriptions_me';
  static const rdvsMe         = '${prefix}rdvs_me';
  static const jobOffers      = '${prefix}job_offers';
  static const services       = '${prefix}services';
  static const servicesForMe  = '${prefix}services_for_me';
  static const countries      = '${prefix}countries';
  static const regions        = '${prefix}regions';
  static const educationLevels = '${prefix}education_levels';
  static const degrees        = '${prefix}degrees';

  static String departments(int regionId) => '${prefix}departments_$regionId';
  static String municipalities(int deptId) => '${prefix}municipalities_$deptId';
}

/// Abstraction du stockage sécurisé (tokens) + cache local (offline).
class SecureStorage {
  SecureStorage(this._secure, this._prefs);

  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  // ── Token JWT ─────────────────────────────────────────────────────────────

  Future<void> saveAccessToken(String token) =>
      _secure.write(key: _SecureKeys.accessToken, value: token);

  Future<String?> getAccessToken() =>
      _secure.read(key: _SecureKeys.accessToken);

  Future<void> saveCredentials(String username, String password) async {
    await _secure.write(key: _SecureKeys.username, value: username);
    await _secure.write(key: _SecureKeys.password, value: password);
  }

  Future<(String, String)?> getCredentials() async {
    final u = await _secure.read(key: _SecureKeys.username);
    final p = await _secure.read(key: _SecureKeys.password);
    if (u == null || p == null) return null;
    return (u, p);
  }

  Future<void> clearAll() async {
    await _secure.deleteAll();
  }

  // ── Cache local JSON (offline) ────────────────────────────────────────────

  Future<void> cacheJson(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  dynamic getCachedJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  Future<void> removeCache(String key) => _prefs.remove(key);

  // ── Helpers clés cache exposées ───────────────────────────────────────────

  static String get applicantMeKey      => _CacheKeys.applicantMe;
  static String get subscriptionsMeKey  => _CacheKeys.subscriptionsMe;
  static String get rdvsMeKey           => _CacheKeys.rdvsMe;
  static String get jobOffersKey        => _CacheKeys.jobOffers;
  static String get servicesKey         => _CacheKeys.services;
  static String get servicesForMeKey    => _CacheKeys.servicesForMe;
  static String get countriesKey        => _CacheKeys.countries;
  static String get regionsKey          => _CacheKeys.regions;
  static String get educationLevelsKey  => _CacheKeys.educationLevels;
  static String get degreesKey          => _CacheKeys.degrees;
  static String departmentsKey(int r)   => _CacheKeys.departments(r);
  static String municipalitiesKey(int d) => _CacheKeys.municipalities(d);
}

// ── Provider ─────────────────────────────────────────────────────────────────

final secureStorageProvider = Provider<SecureStorage>((ref) {
  throw UnimplementedError('Override in ProviderScope with async init');
});

/// À initialiser dans `main.dart` avant le `runApp` :
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// const secure = FlutterSecureStorage();
/// runApp(ProviderScope(
///   overrides: [
///     secureStorageProvider.overrideWithValue(SecureStorage(secure, prefs)),
///   ],
///   child: const SimeApp(),
/// ));
/// ```