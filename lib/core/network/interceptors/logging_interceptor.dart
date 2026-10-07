import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// [LoggingInterceptor] intercepte toutes les requêtes, réponses et erreurs HTTP
/// pour générer des logs lisibles et structurés dans la console.
class LoggingInterceptor extends Interceptor {
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n=== 🚀 HTTP REQUEST ===');
    debugPrint('➡️ METHOD : ${options.method}');
    debugPrint('➡️ URL    : ${options.baseUrl}${options.path}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('➡️ QUERY  : ${options.queryParameters}');
    }
    debugPrint('➡️ HEADERS: ${options.headers}');
    if (options.data != null) {
      debugPrint('➡️ BODY   : ${options.data}');
    }
    debugPrint('=======================\n');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('\n=== ✅ HTTP RESPONSE ===');
    debugPrint('⬅️ STATUS : ${response.statusCode} ${response.statusMessage}');
    debugPrint('⬅️ URL    : ${response.requestOptions.baseUrl}${response.requestOptions.path}');
    if (response.data != null) {
      debugPrint('⬅️ DATA   : ${response.data}');
    }
    debugPrint('========================\n');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('\n=== ❌ HTTP ERROR ===');
    debugPrint('💥 URL    : ${err.requestOptions.baseUrl}${err.requestOptions.path}');
    debugPrint('💥 TYPE   : ${err.type}');
    debugPrint('💥 STATUS : ${err.response?.statusCode} ${err.response?.statusMessage}');
    if (err.response?.data != null) {
      debugPrint('💥 DETAIL : ${err.response?.data}');
    }
    // La cause sous-jacente (err.error) est ce qui explique réellement un
    // DioExceptionType.unknown : SocketException, HandshakeException, etc.
    // err.message est souvent null dans ce cas — d'où l'ancien log inutile.
    debugPrint('💥 MESSAGE: ${err.message}');
    debugPrint('💥 CAUSE  : ${err.error} (${err.error.runtimeType})');
    final cause = err.error;
    if (cause is SocketException) {
      debugPrint('🔎 HINT   : SocketException → hôte/route injoignable ou DNS. '
          'osError=${cause.osError}, address=${cause.address}');
    } else if (cause is HandshakeException) {
      debugPrint('🔎 HINT   : HandshakeException → certificat TLS refusé par '
          "Android (chaîne de certificats incomplète côté serveur, ou horloge "
          "de l'appareil incorrecte). iOS complète la chaîne automatiquement, "
          'pas Android.');
    }
    debugPrint('=====================\n');
    return super.onError(err, handler);
  }
}