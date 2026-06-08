import 'package:equatable/equatable.dart';

enum OffreType { emploi, stage, formation, financement, migration }
enum ContractType { cdi, cdd, stage, interim }

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
    this.level, this.daysLeft = 3,
    this.experienceYears,this.applicantCount, this.sector, this.companySize, 
    this.referenceNumber, this.publishedAt, this.companyDescription, this.missions = const [],
    this.requirements = const [], this.benefits = const [], this.recruitmentSteps = const [],
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

  @override
  List<Object?> get props => [id, title, company, type];

  OffreEntity? copyWith({required bool isSaved}) {}
}

class OffreLevel {
  final String name;
  const OffreLevel._(this.name);

  static const national = OffreLevel._('National');
  static const international = OffreLevel._('International');
}
