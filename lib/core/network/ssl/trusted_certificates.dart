// core/network/ssl/trusted_certificates.dart
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Chemin de l'asset où déposer le(s) certificat(s) intermédiaire(s) manquant(s).
const String kExtraTrustedCertAsset = 'assets/certs/simeanpej-intermediate.pem';

/// Charge le(s) certificat(s) TLS additionnel(s) à faire approuver par l'app.
///
/// Contexte : le serveur `simeanpej.ansd.sn` ne renvoie pas son certificat
/// intermédiaire, si bien qu'Android ne peut pas reconstruire la chaîne
/// jusqu'à une racine de confiance (`CERTIFICATE_VERIFY_FAILED: unable to get
/// local issuer certificate`). On corrige idéalement côté serveur ; à défaut,
/// on embarque le(s) certificat(s) manquant(s) dans [kExtraTrustedCertAsset] et
/// on les ajoute au magasin de confiance de l'app — SANS désactiver la
/// vérification TLS (contrairement à un `badCertificateCallback => true`).
///
/// Retourne `null` si aucun certificat n'est fourni (asset absent ou vide) :
/// l'app se comporte alors exactement comme avant, avec la validation TLS
/// standard du système.
Future<Uint8List?> loadExtraTrustedCertificates() async {
  try {
    final data = await rootBundle.load(kExtraTrustedCertAsset);
    final bytes = data.buffer.asUint8List();
    if (bytes.isEmpty) return null;
    return bytes;
  } catch (_) {
    // Asset non déclaré / introuvable → aucun certificat additionnel.
    if (kDebugMode) {
      debugPrint(
        'ℹ️ Aucun certificat intermédiaire embarqué ($kExtraTrustedCertAsset) : '
        'validation TLS système standard.',
      );
    }
    return null;
  }
}
