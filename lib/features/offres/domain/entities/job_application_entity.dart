// features/offres/domain/entities/job_application_entity.dart

/// Résultat d'une candidature à une offre d'emploi.
///
/// POST /applicant/api/job-offer-applicants/me
/// Le serveur renvoie l'enregistrement créé ; on n'en retient que l'essentiel
/// pour refléter l'état côté UI (identifiant + statut de traitement).
class JobApplicationEntity {
  /// Identifiant de la candidature créée.
  final int id;

  /// Booléen `status` de la ligne (active/archivée).
  final bool active;

  /// Statut de traitement de la candidature (`offAppStatus`), ex. « PENDING ».
  final String? status;

  const JobApplicationEntity({
    required this.id,
    this.active = true,
    this.status,
  });
}
