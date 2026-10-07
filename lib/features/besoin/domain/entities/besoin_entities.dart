// features/besoin/domain/entities/besoin_entities.dart
//
// Entités du parcours « Choisir un besoin sollicité » — la souscription d'un
// candidat à un service du Guichet Unique se fait en trois choix en cascade :
//
//   1. TypeServiceEntity     → la « Catégorie de service » / Besoin sollicité
//                              (ex. Mobilité Internationale, Formation…).
//   2. PartnerServiceEntity  → la « Structure » partenaire qui fournit ce
//                              type de service (ex. CSAEM).
//   3. ServiceOfferEntity    → la « Sous-catégorie » / Offre de service
//                              concrète (ex. Candidat pour la migration).
//
// Chaque niveau est chargé dynamiquement à partir du choix précédent (voir
// `BesoinRemoteDataSource` / `BesoinNotifier`). Certaines catégories ne
// proposent ni structure ni sous-service : l'UI retombe alors sur « Non requis
// pour cette catégorie de service » (même comportement que le front web).

import 'package:flutter/material.dart';

import '../../../../core/design_system/tokens/app_colors.dart';

/// Habillage visuel d'une catégorie de service, dérivé de son `code`/`name`
/// pour donner une identité colorée cohérente avec la charte ANPEJ (voir
/// `AppColors`) sans dépendre d'un champ couleur côté API — inexistant.
class BesoinVisual {
  const BesoinVisual({required this.icon, required this.color, required this.background});

  final IconData icon;
  final Color color;
  final Color background;
}

/// Niveau 1 — Catégorie de service (Besoin sollicité).
///
/// GET /applicant/api/type-services/possible-for-me
class TypeServiceEntity {
  const TypeServiceEntity({
    required this.id,
    required this.status,
    this.code,
    this.name,
  });

  final int id;
  final bool status;
  final String? code;
  final String? name;

  /// Libellé affichable — retombe sur le code puis sur un texte générique
  /// pour ne jamais afficher une chaîne vide dans un menu déroulant.
  String get label {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final c = code?.trim();
    if (c != null && c.isNotEmpty) return c;
    return 'Service #$id';
  }

  /// Catégorie « Financement (Auto-Emploi) » : avant de demander une
  /// structure et une sous-catégorie, on demande au candidat s'il a déjà une
  /// idée de projet. Sans idée de projet, seul le besoin sollicité est envoyé.
  ///
  /// L'API n'expose pas de code dédié connu : détection sur le code puis le
  /// nom, normalisés (accents, casse, espaces, tirets et parenthèses ignorés).
  bool get isAutoEmploi {
    String norm(String? v) => (v ?? '')
        .toLowerCase()
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[^a-z]'), '');
    return norm(code).contains('autoemploi') || norm(name).contains('autoemploi');
  }

  /// Icône + couleurs déduites du domaine métier (mobilité, formation,
  /// financement, emploi, entrepreneuriat…) à partir du code ou du nom.
  BesoinVisual get visual {
    final key = '${code ?? ''} ${name ?? ''}'.toLowerCase();

    if (key.contains('mobilit') || key.contains('migration') || key.contains('diaspora')) {
      return const BesoinVisual(
        icon: Icons.flight_takeoff_rounded,
        color: AppColors.violetANPEJDark,
        background: AppColors.violetANPEJBg,
      );
    }
    if (key.contains('formation') || key.contains('capacit') || key.contains('appui')) {
      return const BesoinVisual(
        icon: Icons.school_rounded,
        color: AppColors.bleuANPEJDark,
        background: AppColors.bleuANPEJBg,
      );
    }
    if (key.contains('financ') || key.contains('credit') || key.contains('crédit') || key.contains('incub')) {
      return const BesoinVisual(
        icon: Icons.savings_rounded,
        color: AppColors.accent900,
        background: AppColors.accent100,
      );
    }
    if (key.contains('entrep') || key.contains('auto') || key.contains('agri')) {
      return const BesoinVisual(
        icon: Icons.storefront_rounded,
        color: AppColors.primary800,
        background: AppColors.primary100,
      );
    }
    if (key.contains('emploi') || key.contains('travail') || key.contains('stage')) {
      return const BesoinVisual(
        icon: Icons.work_rounded,
        color: AppColors.primary800,
        background: AppColors.primary100,
      );
    }
    // Défaut institutionnel — marron ANPEJ.
    return const BesoinVisual(
      icon: Icons.grid_view_rounded,
      color: AppColors.secondary800,
      background: AppColors.secondary100,
    );
  }
}

/// Niveau 2 — Structure partenaire fournissant le type de service choisi.
///
/// GET /applicant/api/partner-services/possible-for-me?typeServiceId={id}
class PartnerServiceEntity {
  const PartnerServiceEntity({
    required this.id,
    required this.status,
    this.code,
    this.name,
    this.officeId,
  });

  final int id;
  final bool status;
  final String? code;
  final String? name;
  final int? officeId;

  String get label {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final c = code?.trim();
    if (c != null && c.isNotEmpty) return c.toUpperCase();
    return 'Structure #$id';
  }
}

/// Niveau 3 — Sous-catégorie / Offre de service concrète.
///
/// GET /applicant/api/services/possible-for-me?partnerServiceId={p}&typeServiceId={t}
class ServiceOfferEntity {
  const ServiceOfferEntity({
    required this.id,
    required this.status,
    this.code,
    this.name,
    this.typeServiceId,
    this.partnerServiceId,
    this.firstRvAutoRequired = false,
  });

  final int id;
  final bool status;
  final String? code;
  final String? name;
  final int? typeServiceId;
  final int? partnerServiceId;

  /// Le backend signale ici si une prise de rendez-vous automatique est
  /// attendue après la souscription (`firstRvAutoRequired`). Non exploité pour
  /// déclencher le RDV dans cette première version (l'utilisateur a choisi de
  /// rediriger vers « Mon dossier »), mais conservé pour un branchement
  /// ultérieur sur POST /rdv/api/rdvs/me/auto.
  final bool firstRvAutoRequired;

  String get label {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final c = code?.trim();
    if (c != null && c.isNotEmpty) return c;
    return 'Offre #$id';
  }
}
