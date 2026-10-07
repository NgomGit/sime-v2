// features/profile/presentation/providers/profile_completion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/profile/domain/entities/profile_completion.dart';
import 'package:sime_v2/features/profile/presentation/providers/applicant_notifier.dart';

/// Expose l'état de complétion du profil ([ProfileCompletion]) dérivé du
/// dossier candidat courant.
///
/// C'est l'unique source de vérité consultée par l'UI pour (dé)verrouiller le
/// parcours « Exprimer un besoin » : la section accueil, la carte CTA du
/// tableau de bord et les états vides de « Mon dossier » observent ce provider
/// et ne restent actifs que lorsque [ProfileCompletion.canExpressBesoin] est
/// vrai.
///
/// Chargement paresseux : dès que la complétion est observée quelque part alors
/// que le profil n'est pas encore en mémoire, on déclenche un chargement
/// offline-first (réseau puis cache Hive). Cela garantit que le verrou
/// fonctionne même si l'utilisateur n'a pas encore ouvert l'onglet Profil (ex.
/// accès direct à « Mon dossier » via un lien profond).
final profileCompletionProvider = Provider<ProfileCompletion>((ref) {
  final state = ref.watch(applicantNotifierProvider);

  if (state.applicant == null && !state.isLoading) {
    // Effet de bord différé pour ne pas muter un provider pendant sa
    // construction.
    Future.microtask(
      () => ref.read(applicantNotifierProvider.notifier).ensureLoaded(),
    );
  }

  return ProfileCompletion.fromApplicant(state.applicant);
});
