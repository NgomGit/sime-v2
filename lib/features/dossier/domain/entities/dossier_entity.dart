import 'package:equatable/equatable.dart';

enum DossierStatus { enAttente, enCours, traite, accepte, rejete }
enum ServiceType { emploiSalarie, financement, formation, mobiliteInt, agrijeunes }

class DossierEntity extends Equatable {
  const DossierEntity({
    required this.id,
    required this.referenceNumber,
    required this.serviceType,
    required this.status,
    required this.currentStep,
    required this.totalSteps,
    this.createdAt,
    this.updatedAt,
    this.conseillerName,
    this.notes,
  });

  final String id;
  final String referenceNumber;
  final ServiceType serviceType;
  final DossierStatus status;
  final int currentStep;
  final int totalSteps;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? conseillerName;
  final String? notes;

  double get progressRatio => currentStep / totalSteps;
  int get progressPercent  => (progressRatio * 100).round();

  @override
  List<Object?> get props => [id, referenceNumber, status, currentStep];
}
