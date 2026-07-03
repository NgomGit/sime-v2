/// SIME v2 — Constantes API
/// Base URL : Gateway Spring Cloud sur port 9010
/// Tous les appels passent par le Gateway — jamais directement sur les ports services.
abstract final class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:9010';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login           = '/api/auth/login';
  static const String register        = '/api/auth/register';
  static const String forgotPassword  = '/api/auth/forgotten-password';
  static const String me              = '/api/auth/me';
  static const String changePassword  = '/api/auth/me/change-password';

  // ── Applicants ───────────────────────────────────────────────────────────
  static const String applicantMe     = '/api/applicants/me';
  static const String applicantRegister = '/api/applicants/register';

  // ── Subscriptions ─────────────────────────────────────────────────────────
  static const String subscriptionsMe = '/api/subscriptions/me';
  static const String subscriptions   = '/api/subscriptions';

  // ── Job Offers ────────────────────────────────────────────────────────────
  static const String jobOffersAvailable = '/api/job-offers/available';

  // ── RDV ──────────────────────────────────────────────────────────────────
  static const String rdvsMe          = '/api/rdvs/me';
  static const String rdvs            = '/api/rdvs';
  static const String rdvAutoBook     = '/api/rdvs/me/auto';
  static String rdvById(int id)       => '/api/rdvs/$id';

  // ── Services ANPEJ ───────────────────────────────────────────────────────
  static const String services        = '/api/services';
  static const String servicesForMe   = '/api/services/possible-for-me';

  // ── Référentiels ──────────────────────────────────────────────────────────
  static const String countries       = '/api/countries';
  static const String regions         = '/api/regions';
  static const String departments     = '/api/departments';
  static const String municipalities  = '/api/municipalities';
  static const String educationLevels = '/api/education-levels';
  static const String degrees         = '/api/degrees';
}