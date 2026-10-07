// features/offres/presentation/mappers/offre_presentation_mapper.dart
//
// Convertit les entités de domaine réelles en modèle de présentation unifié
// [OffreEntity] consommé par les widgets. L'`id` est préfixé par le type de
// ressource (`job:` / `training:`) afin que l'écran de détail sache quel
// endpoint interroger depuis la seule chaîne passée par la route.

import '../../domain/entities/job_offer_entity.dart';
import '../../domain/entities/offre_entity.dart';
import '../../domain/entities/training_offer_entity.dart';

const _jobPrefix = 'job:';
const _trainingPrefix = 'training:';
const _externalPrefix = 'external:';

/// Identifiant de ressource décodé depuis un `OffreEntity.id` composite.
class OffreRef {
  const OffreRef({
    required this.isTraining,
    required this.id,
    this.isExternal = false,
  });
  final bool isTraining;
  final bool isExternal;
  final int id;
}

/// Décode `"job:4"` / `"training:7"` (repli : id d'emploi nu si non préfixé).
OffreRef decodeOffreId(String composite) {
  if (composite.startsWith(_externalPrefix)) {
    return OffreRef(
      isExternal: true,
      isTraining: false,
      id: int.tryParse(composite.substring(_externalPrefix.length)) ?? 0,
    );
  }
  if (composite.startsWith(_trainingPrefix)) {
    return OffreRef(
      isTraining: true,
      id: int.tryParse(composite.substring(_trainingPrefix.length)) ?? 0,
    );
  }
  if (composite.startsWith(_jobPrefix)) {
    return OffreRef(
      isTraining: false,
      id: int.tryParse(composite.substring(_jobPrefix.length)) ?? 0,
    );
  }
  return OffreRef(isTraining: false, id: int.tryParse(composite) ?? 0);
}

String jobOfferCompositeId(int id) => '$_jobPrefix$id';
String trainingOfferCompositeId(int id) => '$_trainingPrefix$id';
String externalOfferCompositeId(int id) => '$_externalPrefix$id';

ContractType? _mapContract(String? name) {
  final n = name?.trim().toUpperCase();
  return switch (n) {
    'CDI' => ContractType.cdi,
    'CDD' => ContractType.cdd,
    'STAGE' => ContractType.stage,
    'INTERIM' || 'INTÉRIM' => ContractType.interim,
    _ => null,
  };
}

/// Date de secours quand l'API ne renvoie pas de clôture (évite un `deadline`
/// non nullable manquant) — 30 jours devant, neutre pour l'affichage d'urgence.
DateTime _fallbackDeadline() => DateTime.now().add(const Duration(days: 30));

// ── Offre d'emploi → OffreEntity ──────────────────────────────────────────────

OffreEntity jobOfferToOffre(JobOfferEntity o) {
  return OffreEntity(
    id: jobOfferCompositeId(o.id),
    title: o.name,
    company: o.companyName,
    location: o.locationLabel,
    type: OffreType.emploi,
    deadline: o.applicEndAt ?? _fallbackDeadline(),
    contractType: _mapContract(o.contract?.name),
    educationLevel: o.educationLevelLabel,
    description: o.description,
    isFeatured: false,
    level: o.forInternational
        ? OffreLevel.international
        : (o.forNational ? OffreLevel.national : null),
    daysLeft: o.daysLeft,
    experienceYears: o.experienceLabel,
    applicantCount: o.applicantCount,
    sector: o.sector,
    referenceNumber: o.reference,
    publishedAt: o.applicStartAt,
    companyDescription: o.companyDescription,
    missions: o.missions,
    requirements: o.requirements,
    benefits: o.benefits,
    skills: o.skillLabels,
    summary: o.summary,
    remuneration: o.remunerationLabel,
    areaExpertise: o.areaExpertiseLabels.isNotEmpty
        ? o.areaExpertiseLabels.first
        : null,
  );
}

// ── Offre de formation → OffreEntity ──────────────────────────────────────────

OffreEntity trainingOfferToOffre(TrainingOfferEntity o) {
  return OffreEntity(
    id: trainingOfferCompositeId(o.id),
    title: o.name,
    company: o.organizerName,
    location: o.locationLabel,
    type: OffreType.formation,
    deadline: o.applicEndAt ?? _fallbackDeadline(),
    contractType: null,
    educationLevel: o.educationLevelLabel,
    description: o.description,
    isFeatured: false,
    level: o.forInternational
        ? OffreLevel.international
        : (o.forNational ? OffreLevel.national : null),
    daysLeft: o.daysLeft,
    experienceYears:
        o.yearsExperience != null ? '${o.yearsExperience} an(s)' : null,
    sector: o.sector,
    referenceNumber: o.reference,
    publishedAt: o.applicStartAt,
    companyDescription: o.companyDescription,
    missions: o.missions,
    benefits: o.benefits,
    skills: o.skillLabels,
    summary: o.summary,
  );
}

// ── Offre d'emploi externe → OffreEntity ──────────────────────────────────────
// Réutilise le mapping emploi (structure identique) en surchargeant l'id
// composite (préfixe `external:`) et le type d'affichage.
OffreEntity externalOfferToOffre(JobOfferEntity o) {
  return jobOfferToOffre(o).copyWith(
    id: externalOfferCompositeId(o.id),
    type: OffreType.externe,
  );
}
