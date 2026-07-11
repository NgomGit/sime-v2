// core/network/interceptors/token_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/providers/secure_storage_provider.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor({required this.ref});

  final Ref ref;

  @override
  void onRequest(options, RequestInterceptorHandler handler) async {
    // 1. Récupération de l'instance SecureStorage via Riverpod
    final secureStorage = ref.read(secureStorageServiceProvider);
    
    // 2. Lecture du jeton d'authentification stocké localement
    final token = await secureStorage.readToken();

    // 3. Si le jeton existe, on l'injecte dans l'en-tête Authorization
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Poursuite normale de la requête HTTP
    return super.onRequest(options, handler);
  }
}