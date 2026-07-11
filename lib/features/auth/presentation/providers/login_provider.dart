// features/auth/presentation/providers/login_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/providers/secure_storage_provider.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/providers/auth_providers.dart';

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
        return LoginState(authResponse: userResponse, isLoading: false);
      }
    }
    return const LoginState(authResponse: null, isLoading: false);
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
      // 2. Sauvegarde du profil complet dans la box Hive chiffrée en AES-256
      await ref.read(hiveCacheProvider).put(_userSessionKey, authResponse.toJson());

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
