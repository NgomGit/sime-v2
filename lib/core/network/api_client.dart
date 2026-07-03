import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import 'api_constants.dart';

/// Client Dio configuré pour le Gateway SIME v2.
/// Injecte automatiquement le JWT Bearer sur chaque requête authentifiée.
class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
  }

  final SecureStorage _storage;
  late final Dio _dio;

  Dio get dio => _dio;
}

/// Intercepteur qui ajoute `Authorization: Bearer <token>` à chaque requête
/// et gère le refresh automatique via `/api/auth/login` si le token expire (401).
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._dio);

  final SecureStorage _storage;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 → tenter un re-login avec les credentials stockés
    if (err.response?.statusCode == 401) {
      final credentials = await _storage.getCredentials();
      if (credentials != null) {
        try {
          final response = await _dio.post(
            ApiConstants.login,
            data: {
              'username': credentials.$1,
              'password': credentials.$2,
            },
          );
          final newToken = response.data['accessToken'] as String;
          await _storage.saveAccessToken(newToken);

          // Rejouer la requête originale avec le nouveau token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retried = await _dio.fetch(opts);
          return handler.resolve(retried);
        } catch (_) {
          // Refresh échoué → invalider la session
          await _storage.clearAll();
        }
      }
    }
    handler.next(err);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});