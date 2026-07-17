// core/utils/maps_launcher.dart
import 'package:url_launcher/url_launcher.dart';

/// Ouvre une localisation dans l'app de cartes par défaut de l'appareil
/// (Google Maps / Apple Maps selon la plateforme).
///
/// Utilise un lien universel `google.com/maps/search` plutôt qu'un schéma
/// `geo:`/`maps:` : fonctionne sur Android et iOS sans configuration
/// native supplémentaire (`LSApplicationQueriesSchemes` / `<queries>`),
/// et retombe sur le navigateur si aucune app de cartes n'est installée.
///
/// Privilégie les coordonnées GPS quand elles sont disponibles (plus
/// précis), sinon recherche par adresse texte.
///
/// Retourne `true` si une app a effectivement pu être ouverte.
Future<bool> openLocationInMaps({
  double? latitude,
  double? longitude,
  String? address,
}) async {
  final hasCoords = latitude != null && longitude != null;
  if (!hasCoords && (address == null || address.trim().isEmpty)) {
    return false;
  }

  final query = hasCoords ? '$latitude,$longitude' : address!.trim();
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
