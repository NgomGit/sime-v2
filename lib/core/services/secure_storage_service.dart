import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // ── Clés de stockage constantes ───────────────────────────────────────────
  static const String _keyAuthToken = 'auth_token';
  static const String _authResponse = 'auth_response';
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedUsername = 'saved_username';
  static const _hiveEncryptionKey = 'hive_crypto_secret_key';


/// Récupère ou génère une clé de chiffrement AES-256 robuste pour Hive
  Future<List<int>> getOrCreateHiveEncryptionKey() async {
    final hexKey = await _storage.read(key: _hiveEncryptionKey);
    
    if (hexKey != null) {
      return base64Url.decode(hexKey);
    }

    // Génération d'une clé sécurisée de 32 octets (256 bits)
    final newKey = Hive.generateSecureKey();
    await _storage.write(key: _hiveEncryptionKey, value: base64Url.encode(newKey));
    return newKey;
  }


  // ── Gestion du Jeton JWT ──────────────────────────────────────────────────
  
  /// Sauvegarde le token JWT
  Future<void> writeToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  /// Récupère le token JWT (renvoie null si inexistant)
  Future<String?> readToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Supprime le token (utile lors du logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyAuthToken);
  }

  // ── Gestion du "Se souvenir de moi" ───────────────────────────────────────

  /// Sauvegarde la préférence de connexion de l'utilisateur
  Future<void> saveRememberMe(bool rememberMe, String? username,) async {
    await _storage.write(key: _keyRememberMe, value: rememberMe.toString());
    if (rememberMe && username != null) {
      await _storage.write(key: _keySavedUsername, value: username);
    } else {
      await _storage.delete(key: _keySavedUsername);
    }
  }

  /// Vérifie si l'utilisateur avait coché "Se souvenir de moi"
  Future<bool> readRememberMe() async {
    final value = await _storage.read(key: _keyRememberMe);
    return value == 'true';
  }

  /// Récupère l'identifiant sauvegardé si rememberMe était actif
  Future<String?> readSavedUsername() async {
    return await _storage.read(key: _keySavedUsername);
  }

  //save auth response
  Future<void> saveAuthResponse(AuthResponseModel authResponse) async {
    await _storage.write(key: _authResponse, value: authResponse.toJson().toString());
  }

  // ── Nettoyage Global ──────────────────────────────────────────────────────

  /// Efface l'intégralité du stockage sécurisé lié à l'application
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}