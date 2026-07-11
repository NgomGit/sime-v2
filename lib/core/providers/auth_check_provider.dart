// features/auth/presentation/providers/auth_check_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';

enum AuthStatus { authenticated, unauthenticated }

final authCheckProvider = FutureProvider<AuthStatus>((ref) async {
  try {
    // 1. On accède au notifier de login (qui gère déjà l'initialisation et le cache Hive)
    ref.read(loginNotifierProvider.notifier);
    
    // Attendre que le notifier soit prêt (Lecture du cache Hive effectuée)
    final loginState = await ref.read(loginNotifierProvider.future);
    
    if (loginState.authResponse != null && loginState.authResponse!.token.isNotEmpty) {
      return AuthStatus.authenticated;
    }
    return AuthStatus.unauthenticated;
  } catch (_) {
    return AuthStatus.unauthenticated;
  }
});