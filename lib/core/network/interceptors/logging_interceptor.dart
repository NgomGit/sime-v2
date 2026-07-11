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
    } else {
      debugPrint('💥 MESSAGE: ${err.message}');
    }
    debugPrint('=====================\n');
    return super.onError(err, handler);
  }
}