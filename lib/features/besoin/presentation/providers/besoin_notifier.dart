// features/besoin/presentation/providers/besoin_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sime_v2/core/network/network_info.dart';

import '../../domain/entities/besoin_entities.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../../domain/repositories/besoin_repository.dart';
import '../../providers/besoin_providers.dart';

/// État du parcours « Nouveau besoin » (sélection en cascade + soumission).
///
/// Trois niveaux de liste (catégories → structures → sous-services) et leurs
/// sélections respectives coexistent, avec des drapeaux de chargement séparés
/// pour que chaque menu déroulant affiche son propre état sans bloquer les
/// autres. `isOffline` / `errorMessage` pilotent le bandeau non bloquant de
/// l'écran (cohérent avec l'écran Agenda).
class BesoinState {
  const BesoinState({
    this.typeServices = const [],
    this.partnerServices = const [],
    this.services = const [],
    this.selectedTypeService,
    this.selectedPartnerService,
    this.selectedService,
    this.hasProjectIdea,
    this.editing,
    this.isLoadingTypes = false,
    this.isLoadingPartners = false,
    this.isLoadingServices = false,
    this.isSubmitting = false,
    this.isOffline = false,
    this.errorMessage,
  });

  final List<TypeServiceEntity> typeServices;
  final List<PartnerServiceEntity> partnerServices;
  final List<ServiceOfferEntity> services;

  final TypeServiceEntity? selectedTypeService;
  final PartnerServiceEntity? selectedPartnerService;
  final ServiceOfferEntity? selectedService;

  /// Réponse à « Avez-vous une idée de projet ? » (catégorie Auto-Emploi
  /// uniquement). `null` tant que le candidat n'a pas répondu.
  final bool? hasProjectIdea;

  /// Besoin en cours de modification (`null` = création d'un nouveau besoin).
  final MySubscriptionEntity? editing;

  bool get isEditing => editing != null;

  final bool isLoadingTypes;
  final bool isLoadingPartners;
  final bool isLoadingServices;
  final bool isSubmitting;

  final bool isOffline;
  final String? errorMessage;

  /// La question « idée de projet » est-elle posée pour la catégorie choisie ?
  bool get asksProjectIdea => selectedTypeService?.isAutoEmploi ?? false;

  /// Les étapes Structure / Sous-catégorie sont-elles affichées ? Toujours,
  /// sauf en Auto-Emploi tant que le candidat n'a pas répondu « Oui ».
  bool get showsStructureSteps => !asksProjectIdea || hasProjectIdea == true;

  /// Une structure est-elle attendue pour la catégorie choisie ?
  bool get structureRequired => partnerServices.isNotEmpty;

  /// Un sous-service est-il attendu pour la structure choisie ?
  bool get sousServiceRequired => services.isNotEmpty;

  /// L'étape « Structure » est activable dès qu'une catégorie est choisie.
  bool get canPickStructure => selectedTypeService != null && !isLoadingPartners;

  /// L'étape « Sous-service » est activable dès qu'une structure est choisie
  /// (ou qu'aucune structure n'est requise mais que des sous-services existent).
  bool get canPickSousService =>
      selectedTypeService != null &&
      (!structureRequired || selectedPartnerService != null) &&
      !isLoadingServices;

  /// Toutes les conditions sont réunies pour enregistrer le besoin.
  bool get canSubmit {
    if (selectedTypeService == null || isSubmitting) return false;
    if (asksProjectIdea) {
      if (hasProjectIdea == null) return false;
      // Pas d'idée de projet → seul le besoin sollicité est envoyé.
      if (hasProjectIdea == false) return true;
    }
    return _cascadeComplete && (!isEditing || hasChanges);
  }

  /// En modification : la sélection diffère-t-elle du besoin d'origine ?
  /// (évite un PUT inutile quand rien n'a changé).
  bool get hasChanges {
    final e = editing;
    if (e == null) return true;
    final partnerId = showsStructureSteps
        ? selectedPartnerService?.id
        : kAutoEmploiDefaultPartnerId;
    final serviceId = showsStructureSteps ? selectedService?.id : null;
    return selectedTypeService?.id != e.typeService?.id ||
        partnerId != e.partnerService?.id ||
        serviceId != e.service?.id;
  }

  bool get _cascadeComplete =>
      !isLoadingPartners &&
      !isLoadingServices &&
      (!structureRequired || selectedPartnerService != null) &&
      (!sousServiceRequired || selectedService != null);

  BesoinState copyWith({
    List<TypeServiceEntity>? typeServices,
    List<PartnerServiceEntity>? partnerServices,
    List<ServiceOfferEntity>? services,
    TypeServiceEntity? selectedTypeService,
    PartnerServiceEntity? selectedPartnerService,
    ServiceOfferEntity? selectedService,
    bool clearSelectedType = false,
    bool clearSelectedPartner = false,
    bool clearSelectedService = false,
    bool? hasProjectIdea,
    bool clearProjectIdea = false,
    MySubscriptionEntity? editing,
    bool? isLoadingTypes,
    bool? isLoadingPartners,
    bool? isLoadingServices,
    bool? isSubmitting,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BesoinState(
      typeServices: typeServices ?? this.typeServices,
      partnerServices: partnerServices ?? this.partnerServices,
      services: services ?? this.services,
      selectedTypeService:
          clearSelectedType ? null : (selectedTypeService ?? this.selectedTypeService),
      selectedPartnerService: clearSelectedPartner
          ? null
          : (selectedPartnerService ?? this.selectedPartnerService),
      selectedService:
          clearSelectedService ? null : (selectedService ?? this.selectedService),
      hasProjectIdea:
          clearProjectIdea ? null : (hasProjectIdea ?? this.hasProjectIdea),
      editing: editing ?? this.editing,
      isLoadingTypes: isLoadingTypes ?? this.isLoadingTypes,
      isLoadingPartners: isLoadingPartners ?? this.isLoadingPartners,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Auto-Emploi sans idée de projet : le besoin est rattaché d'office à cette
/// structure (id 1), sans sous-catégorie ni gabarit `applicant`.
const int kAutoEmploiDefaultPartnerId = 1;

class BesoinNotifier extends StateNotifier<BesoinState> {
  BesoinNotifier(this._repository, this._networkInfo) : super(const BesoinState());

  final BesoinRepository _repository;
  final NetworkInfo _networkInfo;

  // ── Niveau 1 : catégories de service ──────────────────────────────────────

  Future<void> loadTypeServices({bool silent = false}) async {
    final offlineAtStart = !(await _networkInfo.isConnected);
    if (!silent) state = state.copyWith(isLoadingTypes: true, clearError: true);

    final result = await _repository.getPossibleTypeServices();
    result.fold(
      (failure) => state = state.copyWith(
        isLoadingTypes: false,
        isOffline: offlineAtStart,
        errorMessage: failure.message,
      ),
      (list) => state = state.copyWith(
        isLoadingTypes: false,
        isOffline: offlineAtStart,
        typeServices: list,
        clearError: true,
      ),
    );
  }

  void selectTypeService(TypeServiceEntity type) {
    if (state.selectedTypeService?.id == type.id) return;

    // Réinitialise toute la cascade en aval.
    state = state.copyWith(
      selectedTypeService: type,
      clearSelectedPartner: true,
      clearSelectedService: true,
      clearProjectIdea: true,
      partnerServices: const [],
      services: const [],
      clearError: true,
    );
    // Auto-Emploi : on attend la réponse « idée de projet » avant de charger
    // les structures (voir [setProjectIdea]).
    if (type.isAutoEmploi) return;
    _loadPartnerServices(type.id);
  }

  /// Réponse à « Avez-vous une idée de projet ? ».
  ///  - Oui → la cascade Structure → Sous-catégorie reprend normalement.
  ///  - Non → structure et sous-catégorie sont écartées : seul le besoin
  ///    sollicité sera envoyé.
  void setProjectIdea(bool value) {
    final type = state.selectedTypeService;
    if (type == null || state.hasProjectIdea == value) return;

    state = state.copyWith(
      hasProjectIdea: value,
      clearSelectedPartner: true,
      clearSelectedService: true,
      partnerServices: const [],
      services: const [],
      clearError: true,
    );
    if (value) _loadPartnerServices(type.id);
  }

  // ── Niveau 2 : structures partenaires ─────────────────────────────────────

  /// [preselectPartnerId] / [preselectServiceId] : utilisés en modification
  /// pour restaurer la sélection d'origine une fois les listes chargées.
  Future<void> _loadPartnerServices(
    int typeServiceId, {
    int? preselectPartnerId,
    int? preselectServiceId,
  }) async {
    final offlineAtStart = !(await _networkInfo.isConnected);
    state = state.copyWith(isLoadingPartners: true, clearError: true);

    final result = await _repository.getPossiblePartnerServices(typeServiceId);
    await result.fold<Future<void>>(
      (failure) async => state = state.copyWith(
        isLoadingPartners: false,
        isOffline: offlineAtStart,
        errorMessage: failure.message,
      ),
      (list) async {
        // Réponse périmée : catégorie changée ou « Non » choisi entre-temps.
        if (state.selectedTypeService?.id != typeServiceId ||
            !state.showsStructureSteps) {
          state = state.copyWith(isLoadingPartners: false);
          return;
        }
        state = state.copyWith(
          isLoadingPartners: false,
          isOffline: offlineAtStart,
          partnerServices: list,
        );
        // Restauration (modification) sinon confort : une seule structure
        // possible → on la présélectionne, puis on enchaîne sur ses
        // sous-services. Le choix reste visible et modifiable dans l'UI.
        PartnerServiceEntity? toSelect;
        if (preselectPartnerId != null) {
          for (final p in list) {
            if (p.id == preselectPartnerId) toSelect = p;
          }
        }
        if (toSelect == null && list.length == 1) toSelect = list.first;
        if (toSelect != null) {
          return _selectPartner(toSelect, preselectServiceId: preselectServiceId);
        }
      },
    );
  }

  void selectPartnerService(PartnerServiceEntity partner) {
    if (state.selectedPartnerService?.id == partner.id) return;
    _selectPartner(partner);
  }

  Future<void> _selectPartner(
    PartnerServiceEntity partner, {
    int? preselectServiceId,
  }) async {
    final typeId = state.selectedTypeService?.id;
    if (typeId == null) return;

    state = state.copyWith(
      selectedPartnerService: partner,
      clearSelectedService: true,
      services: const [],
      clearError: true,
    );
    await _loadServices(
      partnerServiceId: partner.id,
      typeServiceId: typeId,
      preselectServiceId: preselectServiceId,
    );
  }

  // ── Niveau 3 : sous-services / offres ─────────────────────────────────────

  Future<void> _loadServices({
    required int partnerServiceId,
    required int typeServiceId,
    int? preselectServiceId,
  }) async {
    final offlineAtStart = !(await _networkInfo.isConnected);
    state = state.copyWith(isLoadingServices: true, clearError: true);

    final result = await _repository.getPossibleServices(
      partnerServiceId: partnerServiceId,
      typeServiceId: typeServiceId,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isLoadingServices: false,
        isOffline: offlineAtStart,
        errorMessage: failure.message,
      ),
      (list) {
        // Réponse périmée : structure changée entre-temps.
        if (state.selectedPartnerService?.id != partnerServiceId) {
          state = state.copyWith(isLoadingServices: false);
          return;
        }
        ServiceOfferEntity? restored;
        if (preselectServiceId != null) {
          for (final s in list) {
            if (s.id == preselectServiceId) restored = s;
          }
        }
        state = state.copyWith(
          isLoadingServices: false,
          isOffline: offlineAtStart,
          services: list,
          selectedService: restored,
        );
      },
    );
  }

  void selectService(ServiceOfferEntity service) {
    state = state.copyWith(selectedService: service, clearError: true);
  }

  // ── Modification d'un besoin existant ─────────────────────────────────────

  /// Pré-remplit le formulaire avec [subscription] : charge les catégories,
  /// puis restaure en cascade structure et sous-catégorie.
  Future<void> startEditing(MySubscriptionEntity subscription) async {
    state = BesoinState(editing: subscription);
    await loadTypeServices();

    final original = subscription.typeService;
    if (original == null) return;
    TypeServiceEntity type = original;
    for (final t in state.typeServices) {
      if (t.id == original.id) type = t;
    }

    // Auto-Emploi « Non » = rattaché à la structure par défaut, sans
    // sous-catégorie (voir [_buildPayload]).
    final partnerId = subscription.partnerService?.id;
    final hadProjectIdea = subscription.service != null ||
        (partnerId != null && partnerId != kAutoEmploiDefaultPartnerId);
    state = state.copyWith(
      selectedTypeService: type,
      hasProjectIdea: type.isAutoEmploi ? hadProjectIdea : null,
    );
    if (type.isAutoEmploi && !hadProjectIdea) return;

    await _loadPartnerServices(
      type.id,
      preselectPartnerId: subscription.partnerService?.id,
      preselectServiceId: subscription.service?.id,
    );
  }

  // ── Soumission ────────────────────────────────────────────────────────────

  /// Envoie la souscription. Retourne `(true, null)` en cas de succès, ou
  /// `(false, message)` avec le message d'erreur à présenter dans le dialog.
  Future<(bool, String?)> submit() async {
    if (!state.canSubmit) {
      return (false, 'Veuillez compléter les champs requis.');
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final editing = state.editing;
    final result = editing != null
        ? await _repository.updateSubscription(editing.id, _buildPayload())
        : await _repository.createSubscription(_buildPayload());

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, errorMessage: failure.message);
        return (false, failure.message);
      },
      (_) {
        state = state.copyWith(isSubmitting: false);
        return (true, null);
      },
    );
  }

  /// Corps du POST /applicant/api/subscriptions/me.
  ///
  /// On reproduit fidèlement l'ossature envoyée par le front web (objet
  /// `applicant` pré-initialisé à vide) : l'endpoint `/me` identifie le
  /// candidat via le jeton d'authentification, l'objet `applicant` n'est qu'un
  /// gabarit de formulaire côté client. Seuls les trois identifiants de
  /// service portent l'information réelle. `partnerService`/`service` ne sont
  /// inclus que s'ils ont été sélectionnés (certaines catégories n'en exigent
  /// pas — cf. « Non requis pour cette catégorie de service »).
  Map<String, dynamic> _buildPayload() {
    // Auto-Emploi sans idée de projet : corps minimal attendu par le backend,
    // ex. {"typeService":{"id":6},"partnerService":{"id":1}}.
    if (state.asksProjectIdea && state.hasProjectIdea == false) {
      return {
        'typeService': {'id': state.selectedTypeService!.id},
        'partnerService': {'id': kAutoEmploiDefaultPartnerId},
      };
    }
    return {
      'applicant': {
        'identities': [
          {'type': '', 'value': '', 'file': <dynamic>[]},
        ],
        'office': <String, dynamic>{},
        'user': {'sex': '', 'roles': <dynamic>[]},
        'userJson': {'sex': '', 'roles': <dynamic>[]},
        'maritalStatus': <String, dynamic>{},
        'educationLevel': <String, dynamic>{},
        'lastDegreeObtained': <String, dynamic>{},
        'fieldStudy': <String, dynamic>{},
      },
      'typeService': {'id': state.selectedTypeService!.id},
      if (state.showsStructureSteps && state.selectedPartnerService != null)
        'partnerService': {'id': state.selectedPartnerService!.id},
      if (state.showsStructureSteps && state.selectedService != null)
        'service': {'id': state.selectedService!.id},
    };
  }

  /// Réinitialise entièrement le formulaire (bouton « Réinitialiser »), en
  /// conservant la liste des catégories déjà chargée.
  void reset() {
    state = BesoinState(typeServices: state.typeServices, editing: state.editing);
  }
}

final besoinNotifierProvider =
    StateNotifierProvider.autoDispose<BesoinNotifier, BesoinState>((ref) {
  final repository = ref.watch(besoinRepositoryProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final notifier = BesoinNotifier(repository, networkInfo);

  // Recharge silencieusement la liste des catégories sur une vraie
  // reconnexion (hors-ligne → en ligne), sans écraser une sélection en cours.
  bool? wasConnected;
  ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) {
    final isConnected = next.value;
    if (isConnected == true && wasConnected == false) {
      notifier.loadTypeServices(silent: true);
    }
    if (isConnected != null) wasConnected = isConnected;
  });

  return notifier;
});
