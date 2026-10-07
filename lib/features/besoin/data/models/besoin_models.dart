// features/besoin/data/models/besoin_models.dart
import 'dart:convert';

import '../../domain/entities/besoin_entities.dart';

/// Corrige le double-encodage UTF-8 fréquemment renvoyé par le Gateway sur les
/// libellés accentués (ex. « MobilitÃ© Internationale » → « Mobilité
/// Internationale »). L'API sert de l'UTF-8 relu comme du Latin-1 ; on inverse
/// l'opération, en retombant sur la chaîne d'origine si elle est déjà propre
/// ou si la reconversion échoue.
String _fixEncoding(String input) {
  if (input.isEmpty) return input;
  // Heuristique : pas de séquence mojibake typique → rien à faire.
  if (!input.contains('Ã') && !input.contains('Â')) return input;
  try {
    return utf8.decode(latin1.encode(input), allowMalformed: false);
  } catch (_) {
    return input;
  }
}

String? _fixNullable(Object? value) {
  final s = value?.toString();
  if (s == null) return null;
  return _fixEncoding(s);
}

/// Extrait de façon sûre l'`id` d'un sous-objet JSON imbriqué.
int? _nestedId(Object? node) =>
    node is Map<String, dynamic> ? node['id'] as int? : null;

// ─────────────────────────────────────────────────────────────────────────────
// Niveau 1 — TypeService (Catégorie / Besoin sollicité)
// ─────────────────────────────────────────────────────────────────────────────
class TypeServiceModel extends TypeServiceEntity {
  const TypeServiceModel({
    required super.id,
    required super.status,
    super.code,
    super.name,
    required this.rawJson,
  });

  /// JSON brut conservé pour un aller-retour de cache Hive fidèle (même pattern
  /// que `RdvModel.rawJson` / `ApplicantModel.rawJson`).
  final Map<String, dynamic> rawJson;

  factory TypeServiceModel.fromJson(Map<String, dynamic> json) {
    return TypeServiceModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as bool? ?? true,
      code: _fixNullable(json['code']),
      name: _fixNullable(json['name'] ?? json['label'] ?? json['libelle']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}

// ─────────────────────────────────────────────────────────────────────────────
// Niveau 2 — PartnerService (Structure)
// ─────────────────────────────────────────────────────────────────────────────
class PartnerServiceModel extends PartnerServiceEntity {
  const PartnerServiceModel({
    required super.id,
    required super.status,
    super.code,
    super.name,
    super.officeId,
    required this.rawJson,
  });

  final Map<String, dynamic> rawJson;

  factory PartnerServiceModel.fromJson(Map<String, dynamic> json) {
    return PartnerServiceModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as bool? ?? true,
      code: _fixNullable(json['code']),
      name: _fixNullable(json['name'] ?? json['label'] ?? json['libelle']),
      officeId: json['officeId'] as int? ?? _nestedId(json['office']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}

// ─────────────────────────────────────────────────────────────────────────────
// Niveau 3 — ServiceOffer (Sous-catégorie / Offre de service)
// ─────────────────────────────────────────────────────────────────────────────
class ServiceOfferModel extends ServiceOfferEntity {
  const ServiceOfferModel({
    required super.id,
    required super.status,
    super.code,
    super.name,
    super.typeServiceId,
    super.partnerServiceId,
    super.firstRvAutoRequired,
    required this.rawJson,
  });

  final Map<String, dynamic> rawJson;

  factory ServiceOfferModel.fromJson(Map<String, dynamic> json) {
    return ServiceOfferModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as bool? ?? true,
      code: _fixNullable(json['code']),
      name: _fixNullable(json['name'] ?? json['label'] ?? json['libelle']),
      typeServiceId: _nestedId(json['typeService']),
      partnerServiceId: _nestedId(json['partnerService']),
      firstRvAutoRequired: json['firstRvAutoRequired'] as bool? ?? false,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}
