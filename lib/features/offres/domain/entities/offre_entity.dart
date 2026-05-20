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

  @override
  List<Object?> get props => [id, title, company, type];
}
