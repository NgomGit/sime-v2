import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'logging_interceptor.dart';

/// [ApiClient] gère la configuration centrale des requêtes HTTP de l'application.
/// 
/// Il centralise l'URL de base, les timeouts, les headers globaux,
/// et intègre un système de logs avancé pour le débogage en mode de développement.
class ApiClient {
  final Dio dio;

  /// URL de base du Gateway de préproduction
  static const String _baseUrl = 'http://10.7.200.51:9010';
  
  /// Délais d'expiration configurés à 180 secondes
  static const Duration _timeout = Duration(seconds: 15);

  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: _timeout,
            receiveTimeout: _timeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _initializeInterceptors();
  }

  /// Initialise les interceptors de Dio.
  /// Les logs de débogage ne sont activés qu'en mode [kDebugMode] (Développement).
  void _initializeInterceptors() {
    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }
    
    // Tu pourras ajouter ici plus tard ton AuthInterceptor pour injecter le token JWT :
    // dio.interceptors.add(AuthInterceptor());
  }
}