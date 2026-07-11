// core/network/network_info.dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vérifie si une connexion réseau est disponible.
class NetworkInfo {
  const NetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  /// True si une interface réseau est active (WiFi/mobile) — ne garantit PAS
  /// un accès internet réel (ex: WiFi connecté mais routeur sans internet).
  Future<bool> get hasNetworkInterface async {
    final result = await _connectivity.checkConnectivity();
    if (result.isEmpty) return false;
    return result.first != ConnectivityResult.none;
  }

  /// Vérifie un accès internet réel via une résolution DNS.
  /// À utiliser en complément de [hasNetworkInterface].
  Future<bool> get hasInternetAccess async {
    try {
      final result = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  /// Vérification complète : interface active ET internet joignable.
  Future<bool> get isConnected async {
    final hasInterface = await hasNetworkInterface;
    if (!hasInterface) return false;
    return hasInternetAccess;
  }
}

// Fournit l'instance de la classe utilitaire (instance Connectivity partagée)
final _connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfo(ref.watch(_connectivityProvider)),
);

// LE COMPOSANT CLÉ : Écoute en temps réel le flux de connectivité,
// avec émission immédiate de l'état actuel + vérification internet réelle.
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final networkInfo = ref.watch(networkInfoProvider);
  final connectivity = ref.watch(_connectivityProvider);

  // 1. Émet immédiatement l'état actuel (corrige l'absence d'émission initiale)
  yield await networkInfo.isConnected;

  // 2. Puis réagit à chaque changement d'interface réseau, en revérifiant
  //    l'accès internet réel (pas seulement l'état de l'interface)
  await for (final _ in connectivity.onConnectivityChanged) {
    yield await networkInfo.isConnected;
  }
});