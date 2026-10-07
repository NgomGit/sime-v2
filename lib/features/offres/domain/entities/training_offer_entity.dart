// features/offres/domain/entities/training_offer_entity.dart
//
// Entité « Offre de formation ».
//   • GET /applicant/api/training-offers/available     (liste paginée)
//   • GET /applicant/api/training-offers/{id}/available (détail)
//
// ⚠️ La forme exacte de la réponse n'a pas été fournie : on reprend par miroir
// la structure des offres d'emploi (mêmes enveloppe et champs partagés). Le
// modèle (`TrainingOfferModel`) lit les champs de façon défensive et conserve
// le JSON brut, de sorte qu'un champ propre à la formation non modélisé reste
// néanmoins mis en cache fidèlement. À affiner dès que le contrat réel est
// confirmé.

import 'job_offer_entity.dart';

class TrainingOfferEntity {
  const TrainingOfferEntity({
    required this.id,
    required this.name,
    this.status = true,
    this.description,
    this.reference,
    this.referencePartner,
    this.summary,
    this.mainTasks,
    this.toolsAndSupports,
    this.remuneration,
    this.yearsExperience,
    this.nbTotal,
    this.nbMaxApplic,
    this.nbRemApplic,
    this.startAt,
    this.duration,
    this.durationType,
    this.applicStartAt,
    this.applicEndAt,
    this.offerSkills = const [],
    this.locationType,
    this.location,
    this.forNational = false,
    this.forInternational = false,
    this.offerStatus,
    this.areaExpertises = const [],
    this.educationLevels = const [],
    this.contract,
    this.partner,
    this.fileUrls = const [],
  });

  final int id;
  final String name;
  final bool status;
  final String? description;
  final String? reference;
  final String? referencePartner;
  final String? summary;
  final String? mainTasks;
  final String? toolsAndSupports;
  final String? remuneration;
  final int? yearsExperience;
  final int? nbTotal;
  final int? nbMaxApplic;
  final int? nbRemApplic;
  final DateTime? startAt;
  final int? duration;
  final String? durationType;
  final DateTime? applicStartAt;
  final DateTime? applicEndAt;
  final List<OfferSkill> offerSkills;
  final String? locationType;
  final String? location;
  final bool forNational;
  final bool forInternational;
  final String? offerStatus;
  final List<NamedRef> areaExpertises;
  final List<NamedRef> educationLevels;
  final NamedRef? contract;
  final PartnerInfo? partner;
  final List<String> fileUrls;

  // ── Getters d'affichage (mêmes règles que JobOfferEntity) ──────────────────

  String get organizerName => partner?.label ?? '—';

  String? get sector => partner?.lineBusiness?.trim().isNotEmpty == true
      ? partner!.lineBusiness
      : null;

  String? get contractLabel => contract?.label;

  String get locationLabel {
    final type = locationType?.trim().toUpperCase();
    final loc = location?.trim();
    switch (type) {
      case 'REMOTE':
        return 'À distance (En ligne)';
      case 'HYBRID':
        return loc != null && loc.isNotEmpty ? 'Hybride · $loc' : 'Hybride';
      case 'ONSITE':
        return loc != null && loc.isNotEmpty ? loc : 'En présentiel';
    }
    if (loc != null && loc.isNotEmpty) return loc;
    if (forInternational) return 'International';
    if (forNational) return 'National';
    return '—';
  }

  String? get educationLevelLabel {
    for (final e in educationLevels) {
      final l = e.name?.trim();
      if (l != null && l.isNotEmpty) return l;
    }
    return null;
  }

  List<String> get skillLabels =>
      offerSkills.map((o) => o.skill.label).where((l) => l.isNotEmpty).toList();

  String? get durationLabel {
    if (duration == null) return null;
    final unit = switch (durationType?.trim().toUpperCase()) {
      'YEAR' => duration == 1 ? 'an' : 'ans',
      'MONTH' => 'mois',
      'WEEK' => duration == 1 ? 'semaine' : 'semaines',
      'DAY' => duration == 1 ? 'jour' : 'jours',
      _ => '',
    };
    return unit.isEmpty ? '$duration' : '$duration $unit';
  }

  int get daysLeft {
    final end = applicEndAt;
    if (end == null) return 0;
    final diff = end.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isApplicationOpen {
    final now = DateTime.now();
    final start = applicStartAt;
    final end = applicEndAt;
    if (start != null && now.isBefore(start)) return false;
    if (end != null && now.isAfter(end)) return false;
    return true;
  }

  List<String> get missions => JobOfferEntity.splitToList(mainTasks);

  List<String> get benefits {
    final out = <String>[];
    final tools = toolsAndSupports?.trim();
    if (tools != null && tools.isNotEmpty) out.add('Outils & supports : $tools');
    return out;
  }

  String? get companyDescription {
    final p = partner;
    if (p == null) return null;
    final bits = <String>[];
    if (p.type?.trim().isNotEmpty == true) bits.add(p.type!.trim());
    if (p.lineBusiness?.trim().isNotEmpty == true) {
      bits.add('secteur ${p.lineBusiness!.trim()}');
    }
    final place = [
      if (p.address?.trim().isNotEmpty == true) p.address!.trim(),
      if (p.countryName?.trim().isNotEmpty == true) p.countryName!.trim(),
    ].join(', ');
    if (place.isNotEmpty) bits.add('basé à $place');
    if (bits.isEmpty) return null;
    final sentence = bits.join(', ');
    return '${sentence[0].toUpperCase()}${sentence.substring(1)}.';
  }
}
