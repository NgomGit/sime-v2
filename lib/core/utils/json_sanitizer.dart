// core/utils/json_sanitizer.dart

/// Ramène récursivement une [Map] à des types JSON-safe (`null`, `String`,
/// `num`, `bool`, `List`, `Map`) — le seul type de données qu'on doit envoyer
/// sur le réseau ou écrire dans Hive.
///
/// Toute entrée non déjà JSON-safe (typiquement une entité/modèle Dart
/// glissée par erreur dans un payload de mise à jour) est réduite à son `id`
/// si elle en expose un, sinon à son `toJson()`, sinon supprimée du résultat
/// (avec un message de debug pour retrouver l'origine du bug).
///
/// Utilisé à deux endroits qui doivent rester synchronisés :
///  • [ApplicantRemoteDataSourceImpl.updateApplicantProfile] avant l'envoi
///    HTTP (évite un 400 côté backend si une entité brute traîne).
///  • [ApplicantRepositoryImpl.updateApplicantProfile] avant la mise en cache
///    hors-ligne (évite un `HiveError: Cannot write, unknown type: ...` — Hive
///    n'accepte que des types primitifs ou des adapters enregistrés).
Map<String, dynamic> sanitizeForTransport(
  Map<String, dynamic> input, {
  void Function(String message)? onUnsupported,
}) {
  final result = <String, dynamic>{};

  input.forEach((key, value) {
    final sanitized = _sanitizeValue(value, onUnsupported);
    if (sanitized is _Unsupported) {
      onUnsupported?.call(
        'Champ "$key" retiré du payload : type non sérialisable (${value.runtimeType}). '
        'Vérifie où ce champ est construit — il ne devrait contenir qu\'un id, pas l\'entité complète.',
      );
      return;
    }
    result[key] = sanitized;
  });

  return result;
}

dynamic _sanitizeValue(dynamic value, void Function(String message)? onUnsupported) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is List) {
    return value.map((v) => _sanitizeValue(v, onUnsupported)).toList();
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _sanitizeValue(v, onUnsupported)));
  }

  try {
    final dynamic dyn = value;
    final id = dyn.id;
    if (id is int || id is String) return id;
  } catch (_) {}

  try {
    final dynamic dyn = value;
    final json = dyn.toJson();
    if (json is Map) return _sanitizeValue(json, onUnsupported);
  } catch (_) {}

  return const _Unsupported();
}

class _Unsupported {
  const _Unsupported();
}
