import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/interceptors/auth_interceptor.dart';
import 'package:sime_v2/core/network/interceptors/token_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// [ApiClient] gère la configuration centrale des requêtes HTTP de l'application.
class ApiClient {
  final Dio dio;
  final Ref ref; // Ajout de la référence Riverpod

  /// URL de base du Gateway de préproduction
  // static const String _baseUrl = 'https://simeanpej.ansd.sn';
  static const String _baseUrl = 'http://10.7.200.53:9010';


  /// Délais d'expiration configurés à 15 secondes
  static const Duration _timeout = Duration(seconds: 15);

  ApiClient({required this.ref})
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
    _configureHttps();
  }

  /// Initialise les interceptors de Dio.
  void _initializeInterceptors() {
    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }
    
    dio.interceptors.add(TokenInterceptor(ref: ref));
    // Ajout propre de l'intercepteur avec la référence injectée
    dio.interceptors.add(AuthInterceptor(ref: ref));
  }

  /// Ajoute au magasin de confiance TLS le(s) certificat(s) intermédiaire(s)
  /// embarqué(s) (voir [extraTrustedCertificatesProvider]) lorsque le serveur
  /// ne renvoie pas sa chaîne complète. Sans certificat fourni, on ne touche
  /// pas à l'adaptateur : Dio conserve la validation TLS système par défaut.
  void _configureHttps() {
    final extraCerts = ref.read(extraTrustedCertificatesProvider);
    if (extraCerts == null) return;

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final context = SecurityContext(withTrustedRoots: true)
          ..setTrustedCertificatesBytes(extraCerts);
        return HttpClient(context: context);
      },
    );
  }
}

/// Octets des certificats intermédiaires additionnels à approuver (chaîne
/// incomplète côté serveur). Vaut `null` par défaut ; surchargé au démarrage
/// dans `main.dart` via `loadExtraTrustedCertificates`.
final extraTrustedCertificatesProvider = Provider<Uint8List?>((ref) => null);

// Transmission de la référence 'ref' au constructeur de l'ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref: ref));