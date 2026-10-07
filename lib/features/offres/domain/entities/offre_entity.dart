import 'package:equatable/equatable.dart';

enum OffreType { emploi, stage, formation, externe, financement, migration }
enum ContractType { cdi, cdd, stage, interim }

/// Modèle de présentation d'une offre (emploi ou formation) — vue unifiée
/// consommée par les widgets de la feature `offres`. Alimenté à partir des
/// entités de domaine réelles ([JobOfferEntity] / [TrainingOfferEntity]) via
/// `offre_presentation_mapper.dart`.
class OffreEntity extends Equatable {
  const OffreEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.deadline,
    this.contractType,
    this.educationLevel,
    this.description,
    this.isFeatured = false,
    this.isSaved = false,
    this.level,
    this.daysLeft = 3,
    this.experienceYears,
    this.applicantCount,
    this.sector,
    this.companySize,
    this.referenceNumber,
    this.publishedAt,
    this.companyDescription,
    this.missions = const [],
    this.requirements = const [],
    this.benefits = const [],
    this.recruitmentSteps = const [],
    this.skills = const [],
    this.summary,
    this.remuneration,
    this.areaExpertise,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final OffreType type;
  final DateTime deadline;
  final ContractType? contractType;
  final String? educationLevel;
  final String? description;
  final bool isFeatured;
  final bool isSaved;
  final OffreLevel? level;
  final int daysLeft;
  final String? experienceYears;
  final int? applicantCount;
  final String? sector;
  final String? companySize;
  final String? referenceNumber;
  final DateTime? publishedAt;
  final String? companyDescription;
  final List<String> missions;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> recruitmentSteps;

  /// Compétences attendues (libellés) — surfacées dans le détail de l'offre.
  final List<String> skills;

  /// Sommaire court de l'offre (facultatif).
  final String? summary;

  /// Rémunération déjà formatée (« 60 000 FCFA »).
  final String? remuneration;

  /// Domaine d'expertise principal (facultatif).
  final String? areaExpertise;

  @override
  List<Object?> get props => [id, title, company, type];

  OffreEntity copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    OffreType? type,
    DateTime? deadline,
    ContractType? contractType,
    String? educationLevel,
    String? description,
    bool? isFeatured,
    bool? isSaved,
    OffreLevel? level,
    int? daysLeft,
    String? experienceYears,
    int? applicantCount,
    String? sector,
    String? companySize,
    String? referenceNumber,
    DateTime? publishedAt,
    String? companyDescription,
    List<String>? missions,
    List<String>? requirements,
    List<String>? benefits,
    List<String>? recruitmentSteps,
    List<String>? skills,
    String? summary,
    String? remuneration,
    String? areaExpertise,
  }) {
    return OffreEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      type: type ?? this.type,
      deadline: deadline ?? this.deadline,
      contractType: contractType ?? this.contractType,
      educationLevel: educationLevel ?? this.educationLevel,
      description: description ?? this.description,
      isFeatured: isFeatured ?? this.isFeatured,
      isSaved: isSaved ?? this.isSaved,
      level: level ?? this.level,
      daysLeft: daysLeft ?? this.daysLeft,
      experienceYears: experienceYears ?? this.experienceYears,
      applicantCount: applicantCount ?? this.applicantCount,
      sector: sector ?? this.sector,
      companySize: companySize ?? this.companySize,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      publishedAt: publishedAt ?? this.publishedAt,
      companyDescription: companyDescription ?? this.companyDescription,
      missions: missions ?? this.missions,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      recruitmentSteps: recruitmentSteps ?? this.recruitmentSteps,
      skills: skills ?? this.skills,
      summary: summary ?? this.summary,
      remuneration: remuneration ?? this.remuneration,
      areaExpertise: areaExpertise ?? this.areaExpertise,
    );
  }
}

class OffreLevel {
  final String name;
  const OffreLevel._(this.name);

  static const national = OffreLevel._('National');
  static const international = OffreLevel._('International');
}
