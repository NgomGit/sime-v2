import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // ── Clés de stockage constantes ───────────────────────────────────────────
  static const String _keyAuthToken = 'auth_token';
  static const String _authResponse = 'auth_response';
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedUsername = 'saved_username';

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
  Future<void> saveRememberMe({required bool remember, String? username}) async {
    await _storage.write(key: _keyRememberMe, value: remember.toString());
    if (remember && username != null) {
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