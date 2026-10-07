// features/profile/presentation/providers/applicant_notifier.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sime_v2/features/auth/providers/auth_providers.dart';
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';
import 'package:sime_v2/features/profile/domain/repositories/applicant_repository.dart';
import 'package:sime_v2/features/profile/providers/profile_providers.dart';

/// État exposé par [ApplicantNotifier] à l'ensemble de l'écran Profil.
///
/// Trois signaux orthogonaux permettent à l'UI de réagir précisément à ce
/// qui se passe, plutôt que de dépendre d'un unique booléen :
///  • [isLoading]    → une lecture ou une écriture "au premier plan" est en
///                     cours (justifie un loader bloquant / bouton désactivé).
///  • [isSyncing]    → une synchronisation "arrière-plan" (rejeu des
///                     modifications mises en file d'attente hors-ligne) est
///                     en cours ; ne doit jamais bloquer l'UI, seulement
///                     afficher un indicateur discret (ex. AppBar).
///  • [errorMessage] → dernier message d'erreur "utilisateur" à afficher.
class ApplicantState {
  final ApplicantEntity? applicant;
  final bool isLoading;
  final bool isSyncing;
  final String? errorMessage;

  const ApplicantState({
    this.applicant,
    this.isLoading = false,
    this.isSyncing = false,
    this.errorMessage,
  });

  bool get hasProfile => applicant != null;

  ApplicantState copyWith({
    ApplicantEntity? applicant,
    bool? isLoading,
    bool? isSyncing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ApplicantState(
      applicant: applicant ?? this.applicant,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ApplicantNotifier extends StateNotifier<ApplicantState> {
  final ApplicantRepository _repository;
  final AuthRepository _authRepository;

  ApplicantNotifier(this._repository, this._authRepository) : super(const ApplicantState());

  // ── Lecture ──────────────────────────────────────────────────────────────

  /// Charge (ou recharge) le profil candidat courant.
  ///
  /// Flux standard offline-first : le repository tente le réseau puis
  /// retombe automatiquement sur le cache Hive si hors-ligne ou en cas
  /// d'échec réseau (voir `OfflineFirstMixin.offlineFirst`).
  Future<bool> loadProfile() {
    return _applyResult(() => _repository.getApplicantProfile());
  }

  /// Vrai dès qu'un chargement automatique (paresseux) a été tenté — empêche
  /// les relances en boucle via [ensureLoaded]. N'affecte pas [loadProfile].
  bool _autoLoadAttempted = false;

  /// Charge le profil uniquement s'il n'est pas déjà en mémoire et qu'aucun
  /// chargement n'est en cours. Utilisé par les écrans qui ont besoin de
  /// connaître l'état de complétion du profil (verrou « Exprimer un besoin »)
  /// sans forcément afficher l'onglet Profil — évite les rechargements
  /// redondants tout en garantissant qu'une donnée (réseau ou cache) est
  /// disponible.
  Future<void> ensureLoaded() async {
    // On ne relance jamais automatiquement plus d'une fois : en cas d'échec
    // (hors-ligne sans cache), le verrou « Exprimer un besoin » reste fermé
    // par sécurité, sans marteler le réseau. Un rafraîchissement manuel
    // (pull-to-refresh / bouton Réessayer de l'écran Profil) passe par
    // [loadProfile] et reste, lui, toujours disponible.
    if (state.applicant != null || state.isLoading || _autoLoadAttempted) {
      return;
    }
    _autoLoadAttempted = true;
    await loadProfile();
  }

  // ── Écriture ─────────────────────────────────────────────────────────────

  /// Met à jour les champs "compte utilisateur" (nom, prénom, genre,
  /// téléphone, email, nom d'utilisateur) via PUT /auth/api/auth/me —
  /// remplacement complet de la ressource.
  ///
  /// [editedFields] ne doit contenir QUE les champs réellement modifiables
  /// dans le formulaire (firstName, lastName, sex, phone, email, username).
  /// Le champ obligatoire pour le PUT mais non éditable ici (active) est
  /// automatiquement complété depuis l'utilisateur actuellement en mémoire,
  /// pour éviter de l'écraser avec une valeur nulle côté serveur.
  ///
  /// ⚠️ Ce PUT ne transmet jamais de mot de passe (`changePassword: false`,
  /// pas de clé `password`). Si l'API traite cette route comme un
  /// remplacement *littéral* de la ligne utilisateur (au lieu d'ignorer les
  /// champs absents lorsque `changePassword` est `false`), le mot de passe
  /// stocké côté serveur peut être vidé/invalidé par cet appel — auquel cas
  /// la correction doit se faire côté backend (ne jamais toucher au hash de
  /// mot de passe quand `changePassword` est `false`), pas ici.
  ///
  /// Le endpoint renvoie la ressource "compte utilisateur" (pas le dossier
  /// candidat complet — voir doc de [AuthRepository.updateUserAccount]) : on
  /// fusionne donc ce résultat dans l'applicant courant plutôt que de
  /// remplacer tout l'état, pour ne pas perdre le reste du profil (adresse,
  /// nationalité, identités...).
  Future<bool> updateUserAccountFields(Map<String, dynamic> editedFields) async {
    final currentApplicant = state.applicant;
    final currentUser = currentApplicant?.user;
    if (currentApplicant == null || currentUser == null) return false;

    final fullPayload = <String, dynamic>{
      'id': currentUser.id,
      'firstName': editedFields['firstName'] ?? currentUser.firstName,
      'lastName': editedFields['lastName'] ?? currentUser.lastName,
      'sex': editedFields['sex'] ?? currentUser.sex,
      'username': editedFields['username'] ?? currentUser.username,
      'email': editedFields['email'] ?? currentUser.email,
      'phone': editedFields['phone'] ?? currentUser.phone,
      'active': currentUser.active,
      'changePassword': false,
    };

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authRepository.updateUserAccount(fullPayload);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updatedUser) {
        state = state.copyWith(
          isLoading: false,
          applicant: currentApplicant.copyWith(user: updatedUser),
        );
        return true;
      },
    );
  }

  /// Met à jour partiellement le profil candidat (adresse, région,
  /// nationalité, dernier diplôme, etc.) via PATCH
  /// /applicant/api/applicants/me/{id}.
  ///
  /// [fieldsToUpdate] DOIT rester strictement JSON-safe : cette map part
  /// telle quelle dans le corps de la requête PATCH et peut aussi être mise
  /// en cache par la couche offline (Hive). N'y mets jamais d'entité Dart
  /// brute.
  ///
  /// ⚠️ Ce PATCH n'est pas un vrai patch partiel côté backend : une relation
  /// absente du payload (constaté sur `identities`) est traitée comme "à
  /// vider" plutôt que "à laisser inchangée" — c'est ce qui effaçait la CNI
  /// après toute mise à jour d'identité qui ne la renvoyait pas. Tant que ce
  /// n'est pas corrigé côté API, on réinjecte systématiquement les identités
  /// actuelles dans le payload si l'appelant n'en fournit pas explicitement
  /// (voir [_withPreservedIdentities]). `EditIdentityDocumentScreen` fournit
  /// sa propre clé `identities` (nouveaux scans en base64), qui prend alors
  /// le dessus sans être écrasée par cette réinjection.
  ///
  /// Le PATCH ne renvoie pas le candidat mis à jour (void). Le repository a
  /// néanmoins déjà rafraîchi son cache local en cas de succès : on recharge
  /// donc le profil via [loadProfile] plutôt que de reconstruire chaque champ
  /// modifié à la main. Ceci garantit une unique source de vérité et évite
  /// les champs oubliés ou mal typés (ex. région/département non reflétés,
  /// ou cast invalide sur un champ transmis comme identifiant/texte brut).
  Future<bool> updateProfileFields(Map<String, dynamic> fieldsToUpdate) async {
    final currentApplicant = state.applicant;
    if (currentApplicant == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    final payload = _withPreservedIdentities(fieldsToUpdate, currentApplicant);
    final result = await _repository.updateApplicantProfile(currentApplicant.id, payload);

    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
      return false;
    }

    return loadProfile();
  }

  // ── Synchronisation offline-first ───────────────────────────────────────

  /// Rejoue les modifications mises en file d'attente pendant une période
  /// hors-ligne, puis recharge le profil pour refléter l'état final côté
  /// serveur.
  ///
  /// Expose [ApplicantState.isSyncing] pendant toute la durée de l'opération
  /// afin que l'UI (AppBar, bandeau, indicateur dédié...) puisse donner un
  /// retour visuel non bloquant pendant la synchronisation, conformément au
  /// principe offline-first du projet.
  Future<void> synchronizeOfflineData() async {
    if (state.isSyncing) return; // évite les synchronisations concurrentes
    state = state.copyWith(isSyncing: true);
    try {
      await _repository.synchronizeOfflineData();
      await loadProfile();
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  // ── Aide interne ─────────────────────────────────────────────────────────

  /// Complète [fieldsToUpdate] avec les identités actuelles de
  /// [currentApplicant] si l'appelant n'a pas déjà fourni sa propre clé
  /// `identities` — voir l'avertissement sur [updateProfileFields].
  ///
  /// On renvoie ici la même forme que celle lue depuis l'API
  /// (id/type/value/fileUrls) plutôt qu'un payload de type "nouvel upload"
  /// (qui attend des fichiers en base64) : il n'y a rien de nouveau à
  /// téléverser, l'objectif est uniquement d'éviter que le backend
  /// n'interprète l'absence de la clé comme une suppression.
  Map<String, dynamic> _withPreservedIdentities(
    Map<String, dynamic> fieldsToUpdate,
    ApplicantEntity currentApplicant,
  ) {
    if (fieldsToUpdate.containsKey('identities')) return fieldsToUpdate;

    return {
      ...fieldsToUpdate,
      'identities': currentApplicant.identities
          .map((identity) => {
                'id': identity.id,
                'type': identity.type,
                'value': identity.value,
                'fileUrls': identity.fileUrls,
              })
          .toList(),
    };
  }

  /// Exécute [call], gère [isLoading]/[errorMessage], et remplace
  /// `ApplicantState.applicant` par la valeur retournée en cas de succès.
  /// Utilisé par les flux qui renvoient directement l'entité candidat
  /// complète (aujourd'hui : [loadProfile]).
  Future<bool> _applyResult(Future<Either<Failure, ApplicantEntity>> Function() call) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await call();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (applicant) {
        state = state.copyWith(isLoading: false, applicant: applicant);
        return true;
      },
    );
  }
}

final applicantNotifierProvider = StateNotifierProvider<ApplicantNotifier, ApplicantState>((ref) {
  final repository = ref.watch(applicantRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final notifier = ApplicantNotifier(repository, authRepository);

  // Relance automatiquement la synchronisation dès qu'une connexion est
  // détectée, en passant par le notifier (et non directement par le
  // repository, voir profile_providers.dart) pour que l'UI soit notifiée via
  // ApplicantState.isSyncing et que le profil affiché reste à jour après le
  // rejeu de la file d'attente.
  ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) {
    if (next.value == true) {
      notifier.synchronizeOfflineData();
    }
  });

  return notifier;
});
