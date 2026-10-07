// features/auth/presentation/providers/login_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/providers/secure_storage_provider.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/providers/auth_providers.dart';
import 'package:sime_v2/features/profile/providers/profile_providers.dart';

class LoginState {
  final AuthResponseModel? authResponse;
  final bool isLoading;
  final String? errorMessage;

  const LoginState({this.authResponse, this.isLoading = false, this.errorMessage});
  bool get isAuthenticated => authResponse != null;
}

class LoginNotifier extends AsyncNotifier<LoginState> {
  static const _userSessionKey = 'secure_auth_user_session';

  @override
  Future<LoginState> build() async {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final cache = ref.watch(hiveCacheProvider);

    // Lecture instantanée au boot (depuis la base chiffrée en local)
    final token = await secureStorage.readToken();
    if (token != null) {
      final cachedJson = cache.get(_userSessionKey);
      if (cachedJson != null) {
        final userResponse = AuthResponseModel.fromJson(Map<String, dynamic>.from(cachedJson));
        // Session restaurée : on rafraîchit en tâche de fond le cache du profil
        // demandeur pour qu'il soit disponible hors-ligne même si l'utilisateur
        // n'ouvre jamais l'écran Profil pendant cette session (voir
        // [_prefetchApplicantProfile]). Si hors-ligne, l'appel retombe
        // silencieusement sur le cache existant sans rien casser.
        _prefetchApplicantProfile();
        return LoginState(authResponse: userResponse, isLoading: false);
      }
    }
    return const LoginState(authResponse: null, isLoading: false);
  }

  /// Précharge et met en cache (Hive) le profil complet du demandeur pendant
  /// qu'on est en ligne, sans bloquer le flux d'authentification. Le profil est
  /// ensuite lisible hors-ligne par `ApplicantRepositoryImpl.getApplicantProfile`
  /// (offline-first) même si l'écran Profil n'a jamais été ouvert en ligne.
  void _prefetchApplicantProfile() {
    unawaited(ref.read(applicantRepositoryProvider).getApplicantProfile());
  }

  Future<bool> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncData(LoginState(isLoading: true));
    try {
      final authResponse = await ref.read(authRepositoryProvider).login(username, password);

      // 1. Sauvegarde des tokens dans le stockage sécurisé matériel
      await ref.read(secureStorageServiceProvider).writeToken( authResponse.token);
       // 2. Save remember me preference and username if applicable
      await ref.read(secureStorageServiceProvider).saveRememberMe( rememberMe, username);
      // 3. Sauvegarde du profil complet dans la box Hive chiffrée en AES-256
      await ref.read(hiveCacheProvider).put(_userSessionKey, authResponse.toJson());

      // 4. Précharge le profil demandeur en cache pendant qu'on est en ligne,
      //    pour garantir sa disponibilité hors-ligne (voir _prefetchApplicantProfile).
      _prefetchApplicantProfile();

      state = AsyncData(LoginState(authResponse: authResponse, isLoading: false));
      return true;
    } catch (e) {
      state = AsyncData(LoginState(isLoading: false, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> logout() async {
    // Nettoyage complet et simultané des deux espaces de stockage
    final rememberMe = await ref.read(secureStorageServiceProvider).readRememberMe();
    final username = await ref.read(secureStorageServiceProvider).readSavedUsername();

    await ref.read(secureStorageServiceProvider).clearAll();
    await ref.read(hiveCacheProvider).delete(_userSessionKey);
    await ref.read(secureStorageServiceProvider).saveRememberMe(rememberMe, username);
    
    state = const AsyncData(LoginState(authResponse: null, isLoading: false));

  }
}
// ── Providers Globaux ─────────────────────────────────────────────────────────

final loginNotifierProvider = AsyncNotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  final loginState = ref.watch(loginNotifierProvider).valueOrNull;
  return loginState?.isAuthenticated ?? false;
});
