// features/besoin/domain/entities/my_subscription_entity.dart
//
// Un « besoin sollicité » déjà enregistré par le candidat — une souscription à
// un service du Guichet Unique (GET /applicant/api/subscriptions/me).
//
// Réutilise les entités de sélection ([TypeServiceEntity], [PartnerServiceEntity],
// [ServiceOfferEntity]) pour l'habillage (libellés, icône/couleur du domaine).
// Reste une entité pure (aucun import de couche présentation) : le mapping
// statut → couleur vit dans le badge (`SubscriptionStatusBadge`).

import 'package:flutter/material.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import 'besoin_entities.dart';

class MySubscriptionEntity {
  const MySubscriptionEntity({
    required this.id,
    required this.reference,
    required this.statusSub,
    this.subStatusCode,
    this.subStatusName,
    this.typeService,
    this.partnerService,
    this.service,
    this.extReference,
    this.sentToPartner = false,
    this.hasAdvisor = false,
  });

  final int id;
  final String reference;

  /// Statut « haut niveau » brut (`statusSub`), ex. `IN_VALIDATION`.
  final String statusSub;

  /// Sous-statut détaillé (`subStatus`) — code technique + libellé déjà
  /// localisé côté serveur (ex. « En cours de validation »).
  final String? subStatusCode;
  final String? subStatusName;

  final TypeServiceEntity? typeService;
  final PartnerServiceEntity? partnerService;
  final ServiceOfferEntity? service;

  final String? extReference;
  final bool sentToPartner;
  final bool hasAdvisor;

  /// Code de statut effectif pour le mapping couleur (préfère le sous-statut
  /// détaillé, retombe sur le statut haut niveau).
  String get effectiveStatusCode =>
      (subStatusCode ?? statusSub).trim().toUpperCase();

  /// Libellé de statut affichable — préfère le libellé serveur déjà localisé.
  String get statusLabel {
    final name = subStatusName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return _fallbackLabel(effectiveStatusCode);
  }

  /// Catégorie de service = le « besoin » exprimé (ex. Mobilité Internationale).
  String get besoinLabel => typeService?.label ?? 'Service';

  /// Offre de service concrète choisie (ex. Candidat pour la migration).
  String? get offreLabel => service?.label;

  /// Structure partenaire (ex. CSAEM).
  String? get structureLabel => partnerService?.label;

  /// Nature du statut — enum de domaine (aucune dépendance à la couche UI),
  /// consommé à la fois par le badge et la carte de progression pour dériver
  /// couleur / avancement sans dupliquer le mapping des codes.
  SubscriptionStatusKind get statusKind => switch (effectiveStatusCode) {
        'IN_VALIDATION' => SubscriptionStatusKind.inValidation,
        'VALIDATED' => SubscriptionStatusKind.validated,
        'INVALID' || 'REJECTED' => SubscriptionStatusKind.invalid,
        'READY_FOR_MIGRATION' => SubscriptionStatusKind.ready,
        'FORWARDED_TO_MIGRATION_POLE' => SubscriptionStatusKind.forwarded,
        'RETURNED_TO_FIRST_ADVISOR' => SubscriptionStatusKind.returned,
        'ARCHIVED' || 'CLOSED' => SubscriptionStatusKind.archived,
        'SUSPENDED' => SubscriptionStatusKind.suspended,
        _ => SubscriptionStatusKind.other,
      };

  // ── Avancement (visualisation « dossier ») ────────────────────────────────
  //
  // L'API ne renvoie pas d'avancement numérique : on projette le statut sur un
  // pipeline canonique de jalons pour alimenter la carte de progression. Le
  // premier jalon (« Besoin enregistré ») est acquis dès que la souscription
  // existe. À affiner si le backend expose un jour un vrai pourcentage.
  static const List<String> progressStepLabels = <String>[
    'Besoin enregistré',
    'En cours de validation',
    'Validé',
    'Prêt pour migration',
    'Affecté au pôle',
  ];

  int get progressTotalSteps => progressStepLabels.length;

  /// Étape courante (1-based).
  int get progressCurrentStep => switch (statusKind) {
        SubscriptionStatusKind.forwarded => 5,
        SubscriptionStatusKind.archived => 5,
        SubscriptionStatusKind.ready => 4,
        SubscriptionStatusKind.validated => 3,
        SubscriptionStatusKind.inValidation => 2,
        SubscriptionStatusKind.returned => 2,
        SubscriptionStatusKind.suspended => 2,
        SubscriptionStatusKind.invalid => 2,
        SubscriptionStatusKind.other => 1,
      };

  double get progressRatio => progressCurrentStep / progressTotalSteps;
  int get progressPercent => (progressRatio * 100).round();

  String get progressStepLabel =>
      progressStepLabels[(progressCurrentStep - 1).clamp(0, progressTotalSteps - 1)];

  /// Statut terminal négatif (invalide) — la carte teinte alors l'étape
  /// courante en rouge plutôt qu'en jaune.
  bool get isNegative => statusKind == SubscriptionStatusKind.invalid;

  /// Le candidat peut-il encore modifier / supprimer ce besoin ?
  ///
  /// Règle côté client (le backend reste l'arbitre final) : uniquement tant
  /// que le dossier n'a pas été validé ni transmis à un partenaire.
  bool get isEditable =>
      !sentToPartner &&
      switch (statusKind) {
        SubscriptionStatusKind.inValidation ||
        SubscriptionStatusKind.returned ||
        SubscriptionStatusKind.invalid ||
        SubscriptionStatusKind.other =>
          true,
        _ => false,
      };

  /// Habillage visuel (icône + couleurs) dérivé de la catégorie de service.
  BesoinVisual get visual =>
      typeService?.visual ??
      const BesoinVisual(
        icon: Icons.assignment_outlined,
        color: AppColors.secondary800,
        background: AppColors.secondary100,
      );

  static String _fallbackLabel(String code) => switch (code) {
        'IN_VALIDATION' => 'En cours de validation',
        'VALIDATED' => 'Validé',
        'INVALID' || 'REJECTED' => 'Invalide',
        'ARCHIVED' => 'Archivé',
        'CLOSED' => 'Clôturé',
        'SUSPENDED' => 'Suspendu',
        'READY_FOR_MIGRATION' => 'Prêt pour migration',
        'FORWARDED_TO_MIGRATION_POLE' => 'Affecté au pôle migration',
        'RETURNED_TO_FIRST_ADVISOR' => 'Renvoyé au conseiller',
        _ => code.isEmpty ? 'Statut inconnu' : code,
      };
}

/// Nature métier du statut d'une souscription — enum de domaine partagé entre
/// le badge de statut et la carte de progression.
enum SubscriptionStatusKind {
  inValidation,
  validated,
  invalid,
  ready,
  forwarded,
  returned,
  archived,
  suspended,
  other,
}
