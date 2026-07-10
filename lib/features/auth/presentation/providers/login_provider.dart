// features/auth/presentation/providers/login_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/providers/secure_storage_provider.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sime_v2/features/auth/presentation/providers/registration_provider.dart';

class LoginState {
  final AuthResponseModel? authResponse;
  final bool isLoading;
  final String? errorMessage;

  const LoginState({
    this.authResponse,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => authResponse != null;

  LoginState copyWith({
    AuthResponseModel? authResponse,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      authResponse: authResponse ?? this.authResponse,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Nettoie l'erreur si non spécifiée
    );
  }
}

class LoginNotifier extends AsyncNotifier<LoginState> {
  late final AuthRepository _repository;

  @override
  Future<LoginState> build() async {
    _repository = ref.watch(authRepositoryProvider);
    // Lire le token au démarrage depuis ton service sécurisé
    // final secureStorage = ref.watch(secureStorageServiceProvider);
    // final token = secureStorage..readToken();

    // Optionnel : Tu peux reconstruire un AuthResponseModel minimal avec le token,
    // ou appeler une méthode du repository pour récupérer le profil complet (recommandé)
    // try {
    //   final profile = await _repository.login(username, password);
    //   return LoginState(authResponse: profile, isLoading: false);
    // } catch (_) {
    //   // Si le token est expiré ou invalide, on nettoie tout
    //   await secureStorage.clearAll();
    //   return const LoginState(authResponse: null, isLoading: false);
    // }

     return const LoginState(authResponse: null, isLoading: false);
  }

  /// Méthode de connexion pilotant l'état de chargement et les messages d'erreur
  Future<bool> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    // 1. Déclenchement du Loader dans la UI (on réinitialise l'erreur précédente au passage)
    state = AsyncData(
        state.value?.copyWith(isLoading: true, errorMessage: null) ??
            const LoginState(isLoading: true));

    try {
      // 2. Appel API distant
      final authResponse = await _repository.login(username, password);

      // Si rememberMe est coché, la persistance se fait ici via SecureStorage
      if (rememberMe) {
        await ref
            .read(secureStorageServiceProvider)
            .saveRememberMe(remember: true, username: username);
      }
      // 3. Save the cryptographic parts securely
      await ref
          .read(secureStorageServiceProvider)
          .writeToken(authResponse.token);

      // 4. Succès : Extinction du loader et stockage de la réponse de l'API
      state =
          AsyncData(LoginState(authResponse: authResponse, isLoading: false));
      return true;
    } catch (e) {
      // 4. Échec : Extinction du loader et transmission du message d'erreur
      final errorMsg = e.toString().replaceAll('Exception: ', '');

      state = AsyncData(LoginState(
        authResponse: null,
        isLoading: false,
        errorMessage: errorMsg,
      ));
      return false;
    }
  }

  /// Déconnexion et nettoyage de l'état
  Future<void> logout() async {
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
