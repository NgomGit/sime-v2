// features/offres/domain/entities/job_offer_entity.dart
//
// Entité « Offre d'emploi » alignée sur la réponse réelle du Gateway :
//   • GET /applicant/api/job-offers/available   (liste paginée)
//   • GET /applicant/api/job-offers/{id}/available (détail)
//
// Entité de domaine pure (aucune dépendance à la couche présentation). Les
// libellés déjà nettoyés (double-encodage UTF-8 corrigé côté modèle) sont
// exposés via des getters d'affichage réutilisés par le mapper de présentation
// (`OffreEntity`) et par tout consommateur direct.

/// Référence légère d'une compétence (`offerSkills[].skill.basicInfo`).
class SkillRef {
  const SkillRef({required this.id, this.code, this.name});

  final int id;
  final String? code;
  final String? name;

  String get label {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final c = code?.trim();
    if (c != null && c.isNotEmpty) return c;
    return 'Compétence #$id';
  }
}

/// Compétence attendue pour l'offre, avec son poids (`offerSkills[]`).
class OfferSkill {
  const OfferSkill({required this.id, required this.skill, this.weight = 1.0});

  final int id;
  final SkillRef skill;
  final double weight;
}

/// Référence de type nomenclature (`basicInfo` : contrat, domaine d'expertise…).
class NamedRef {
  const NamedRef({required this.id, this.code, this.name});

  final int id;
  final String? code;
  final String? name;

  String get label {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final c = code?.trim();
    if (c != null && c.isNotEmpty) return c;
    return '#$id';
  }
}

/// Structure partenaire / employeur (`partner.basicInfo`).
class PartnerInfo {
  const PartnerInfo({
    required this.id,
    this.name,
    this.type,
    this.email,
    this.phone,
    this.address,
    this.countryName,
    this.lineBusiness,
  });

  final int id;
  final String? name;
  final String? type;
  final String? email;
  final String? phone;
  final String? address;
  final String? countryName;
  final String? lineBusiness;

  String get label {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Structure #$id';
  }
}

/// Offre d'emploi complète.
class JobOfferEntity {
  const JobOfferEntity({
    required this.id,
    required this.name,
    this.status = true,
    this.description,
    this.reference,
    this.referencePartner,
    this.summary,
    this.jobRequirements,
    this.mainTasks,
    this.toolsAndSupports,
    this.remuneration,
    this.genderTarget,
    this.yearsExperience,
    this.proAttitudes,
    this.nbTotal,
    this.nbAvailable,
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
  final String? jobRequirements;
  final String? mainTasks;
  final String? toolsAndSupports;
  final String? remuneration;
  final String? genderTarget;
  final int? yearsExperience;
  final String? proAttitudes;
  final int? nbTotal;
  final int? nbAvailable;
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

  // ── Getters d'affichage ────────────────────────────────────────────────────

  String get companyName => partner?.label ?? '—';

  String? get sector => partner?.lineBusiness?.trim().isNotEmpty == true
      ? partner!.lineBusiness
      : null;

  String? get contractLabel => contract?.label;

  /// Libellé de localisation dérivé du `locationType` (l'API ne renvoie pas de
  /// texte tout prêt quand le poste est en télétravail).
  String get locationLabel {
    final type = locationType?.trim().toUpperCase();
    final loc = location?.trim();
    switch (type) {
      case 'REMOTE':
        return 'À distance (Télétravail)';
      case 'HYBRID':
        return loc != null && loc.isNotEmpty ? 'Hybride · $loc' : 'Hybride';
      case 'ONSITE':
        return loc != null && loc.isNotEmpty ? loc : 'Sur site';
    }
    if (loc != null && loc.isNotEmpty) return loc;
    if (forInternational) return 'International';
    if (forNational) return 'National';
    return '—';
  }

  /// Premier niveau d'étude requis (libellé).
  String? get educationLevelLabel {
    for (final e in educationLevels) {
      final l = e.name?.trim();
      if (l != null && l.isNotEmpty) return l;
    }
    return null;
  }

  List<String> get skillLabels =>
      offerSkills.map((o) => o.skill.label).where((l) => l.isNotEmpty).toList();

  List<String> get areaExpertiseLabels =>
      areaExpertises.map((a) => a.label).where((l) => l.isNotEmpty).toList();

  String? get experienceLabel =>
      yearsExperience != null ? '$yearsExperience an(s)' : null;

  /// Rémunération formatée (« 60 000 FCFA ») à partir de la chaîne brute.
  String? get remunerationLabel {
    final raw = remuneration?.trim();
    if (raw == null || raw.isEmpty) return null;
    final n = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    if (n == null) return raw;
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '$buf FCFA';
  }

  /// Durée du contrat lisible (« 2 an(s) », « 4 mois »).
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

  /// Nombre de candidatures déjà déposées, dérivé de (max − restantes).
  int? get applicantCount {
    if (nbMaxApplic == null || nbRemApplic == null) return null;
    final used = nbMaxApplic! - nbRemApplic!;
    return used < 0 ? 0 : used;
  }

  /// Jours restants avant la clôture des candidatures (0 si clôturé/absent).
  int get daysLeft {
    final end = applicEndAt;
    if (end == null) return 0;
    final diff = end.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// La fenêtre de candidature est-elle ouverte à l'instant présent ?
  bool get isApplicationOpen {
    final now = DateTime.now();
    final start = applicStartAt;
    final end = applicEndAt;
    if (start != null && now.isBefore(start)) return false;
    if (end != null && now.isAfter(end)) return false;
    return true;
  }

  bool get isPublished =>
      (offerStatus ?? '').trim().toUpperCase() == 'PUBLISHED';

  /// Découpe un champ texte multi-ligne / à puces en éléments de liste.
  static List<String> splitToList(String? raw) {
    if (raw == null) return const [];
    final parts = raw
        .split(RegExp(r'[\r\n;•]+'))
        .map((s) => s.trim().replaceFirst(RegExp(r'^[-*·]\s*'), '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts;
  }

  /// Missions principales sous forme de liste (à partir de `mainTasks`).
  List<String> get missions => splitToList(mainTasks);

  /// Profil recherché = exigences du poste + attitudes professionnelles.
  List<String> get requirements => [
        ...splitToList(jobRequirements),
        ...splitToList(proAttitudes),
      ];

  /// « Ce que nous offrons » : rémunération + outils & supports fournis.
  List<String> get benefits {
    final out = <String>[];
    final rem = remunerationLabel;
    if (rem != null) out.add('Rémunération : $rem');
    final tools = toolsAndSupports?.trim();
    if (tools != null && tools.isNotEmpty) out.add('Outils & supports : $tools');
    return out;
  }

  /// Petit descriptif de la structure composé à partir des infos partenaire.
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
