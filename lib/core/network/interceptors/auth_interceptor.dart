// core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.ref});

  final Ref ref;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Interception des erreurs 401 Unauthorized (Token expiré ou manquant)
    if (err.response?.statusCode == 401) {
      final message = err.response?.data is Map<String, dynamic>
          ? (err.response!.data as Map<String, dynamic>)['message']?.toString()
          : null;

      // Log d'avertissement en console
      debugPrint('=== 🔑 AUTH INTERCEPTOR: 401 DETECTED ($message) ===');

      // 1. Déclenche le logout global (nettoie SecureStorage, Hive Cache et réinitialise l'état)
      await ref.read(loginNotifierProvider.notifier).logout();

      // Note: Si tu as configuré un routeur global réactif comme GoRouter qui observe 
      // isAuthenticatedProvider, la redirection vers AppRoutes.login se fera automatiquement.
      // Sinon, tu peux également ajouter une redirection explicite ici si nécessaire.
    }

    // Laisse l'erreur se propager pour que le mixin ou le repository puisse la mapper
    return super.onError(err, handler);
  }
}