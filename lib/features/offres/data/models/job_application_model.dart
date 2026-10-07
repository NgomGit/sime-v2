// features/offres/data/models/job_application_model.dart
import '../../domain/entities/job_application_entity.dart';

/// Mapping de la réponse de candidature (POST job-offer-applicants/me).
///
/// Payload envoyé : `{"applicant":{"id":..},"jobOffer":{"id":..}}`.
/// Réponse : enregistrement complet dont on ne conserve que `id`, le booléen
/// `status`, et `offAppStatus` (statut métier de la candidature).
class JobApplicationModel extends JobApplicationEntity {
  const JobApplicationModel({
    required super.id,
    super.active,
    super.status,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      active: json['status'] as bool? ?? true,
      status: json['offAppStatus'] as String?,
    );
  }
}
