// features/profile/domain/entities/profile_completion.dart
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';

/// Identifie une section éditable du profil, indépendamment de toute
/// considération d'UI ou de routage (la couche présentation associe chaque
/// [ProfileSectionKind] à son écran d'édition et à son icône).
enum ProfileSectionKind {
  /// « Informations personnelles » — bureau affilié, état civil et résidence.
  personalInfo,

  /// « Situation personnelle » — situation familiale et handicap.
  personalSituation,
}

/// Un champ requis d'une section, avec son libellé lisible, son état de
/// complétion et son [weight] dans le calcul de progression.
///
/// Le poids sert uniquement au pourcentage affiché (retour visuel) : un champ
/// jugé structurant — typiquement le bureau affilié — pèse beaucoup plus qu'un
/// champ ordinaire, si bien que le renseigner fait fortement progresser la
/// jauge.
class ProfileField {
  final String label;
  final bool isFilled;
  final double weight;

  const ProfileField(
    this.label, {
    required this.isFilled,
    this.weight = 1.0,
  });
}

/// Une section du profil et l'état de complétion de ses champs requis.
class ProfileSection {
  final ProfileSectionKind kind;
  final String title;
  final List<ProfileField> fields;

  const ProfileSection({
    required this.kind,
    required this.title,
    required this.fields,
  });

  /// Nombre de champs renseignés / total (pour l'affichage « x/y »).
  int get filledCount => fields.where((f) => f.isFilled).length;

  int get totalCount => fields.length;

  /// Poids cumulé des champs renseignés / total (pour le pourcentage).
  double get filledWeight =>
      fields.where((f) => f.isFilled).fold(0.0, (sum, f) => sum + f.weight);

  double get totalWeight => fields.fold(0.0, (sum, f) => sum + f.weight);

  /// Une section n'est complète que si TOUS ses champs requis sont renseignés.
  bool get isComplete => fields.every((f) => f.isFilled);

  double get progress => totalWeight == 0 ? 0 : filledWeight / totalWeight;

  /// Libellés des champs encore à renseigner (pour l'affichage guidé).
  List<String> get missingLabels =>
      fields.where((f) => !f.isFilled).map((f) => f.label).toList();
}

/// État de complétion du profil candidat, dérivé d'un [ApplicantEntity].
///
/// Règle métier de déverrouillage du parcours « Exprimer un besoin » :
///  1. le bureau affilié doit être renseigné (obligatoire), et
///  2. la progression pondérée doit dépasser [unlockProgressThreshold] (75 %).
///
/// Le profil n'a donc pas besoin d'être rempli à 100 %. Le calcul est
/// volontairement pur (aucune dépendance Flutter/Riverpod) afin de rester
/// testable et réutilisable côté UI comme côté logique.
class ProfileCompletion {
  final ProfileSection personalInfo;
  final ProfileSection personalSituation;

  /// Le bureau affilié est-il renseigné ? Condition obligatoire du
  /// déverrouillage (en plus du seuil de progression).
  final bool bureauFilled;

  const ProfileCompletion({
    required this.personalInfo,
    required this.personalSituation,
    required this.bureauFilled,
  });

  /// Poids du bureau affilié dans la jauge de progression. Volontairement
  /// élevé : choisir son bureau est l'action structurante du profil (rattache
  /// le dossier à un Guichet Unique), on veut donc que ce seul champ fasse
  /// bondir le pourcentage. Ajustable ici sans toucher au reste du calcul.
  static const double bureauWeight = 6.0;

  /// Seuil de progression pondérée à dépasser (strictement) pour débloquer le
  /// parcours « Exprimer un besoin », en complément du bureau affilié.
  static const double unlockProgressThreshold = 0.75;

  /// Sections prises en compte pour le déverrouillage, dans l'ordre d'affichage.
  List<ProfileSection> get sections => [personalInfo, personalSituation];

  bool get personalInfoComplete => personalInfo.isComplete;

  bool get personalSituationComplete => personalSituation.isComplete;

  /// Seul signal que l'UI doit consulter pour (dé)verrouiller le bouton
  /// « Exprimer un besoin ».
  ///
  /// Débloqué dès que le bureau affilié est renseigné ET que la progression
  /// pondérée dépasse [unlockProgressThreshold] (75 %). Sans bureau il reste
  /// bloqué : le bureau seul ne vaut que ~40 %, on ne peut donc pas dépasser
  /// 75 % sans lui.
  bool get canExpressBesoin =>
      bureauFilled && progress > unlockProgressThreshold;

  int get filledCount =>
      sections.fold(0, (sum, section) => sum + section.filledCount);

  int get totalCount =>
      sections.fold(0, (sum, section) => sum + section.totalCount);

  double get _filledWeight =>
      sections.fold(0.0, (sum, section) => sum + section.filledWeight);

  double get _totalWeight =>
      sections.fold(0.0, (sum, section) => sum + section.totalWeight);

  /// Progression globale pondérée (0.0 → 1.0) sur l'ensemble des champs requis.
  double get progress => _totalWeight == 0 ? 0 : _filledWeight / _totalWeight;

  /// Sections encore incomplètes, dans l'ordre d'affichage.
  List<ProfileSection> get incompleteSections =>
      sections.where((s) => !s.isComplete).toList();

  static bool _notBlank(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Construit l'état de complétion à partir du dossier candidat courant.
  ///
  /// Un [applicant] `null` (profil pas encore chargé, ou aucune donnée en
  /// cache hors-ligne) est traité comme « rien de renseigné » : le parcours
  /// reste verrouillé par sécurité tant que la complétude n'a pas pu être
  /// confirmée.
  factory ProfileCompletion.fromApplicant(ApplicantEntity? applicant) {
    // Le bureau est considéré renseigné s'il est présent sous forme d'objet
    // (office) ou d'identifiant à plat (officeId), selon ce que renvoie l'API.
    final hasBureau =
        applicant?.office != null || applicant?.officeId != null;

    return ProfileCompletion(
      bureauFilled: hasBureau,
      personalInfo: ProfileSection(
        kind: ProfileSectionKind.personalInfo,
        title: 'Informations personnelles',
        fields: [
          // Champ structurant et obligatoire, fortement pondéré.
          ProfileField('Bureau affilié',
              isFilled: hasBureau, weight: bureauWeight),
          ProfileField('Date de naissance',
              isFilled: _notBlank(applicant?.dateBirth)),
          ProfileField('Lieu de naissance',
              isFilled: _notBlank(applicant?.placeBirth)),
          ProfileField('Adresse de résidence',
              isFilled: _notBlank(applicant?.address)),
          ProfileField('Région', isFilled: applicant?.residRegion != null),
          ProfileField('Département',
              isFilled: applicant?.residDepartment != null),
          ProfileField('Commune',
              isFilled: applicant?.residMunicipality != null),
          ProfileField('Nationalité', isFilled: applicant?.nationality != null),
        ],
      ),
      personalSituation: ProfileSection(
        kind: ProfileSectionKind.personalSituation,
        title: 'Situation personnelle',
        fields: [
          ProfileField('Situation matrimoniale',
              isFilled: applicant?.maritalStatus != null),
          ProfileField("Nombre d'enfants",
              isFilled: applicant?.nbChildren != null),
        ],
      ),
    );
  }
}
