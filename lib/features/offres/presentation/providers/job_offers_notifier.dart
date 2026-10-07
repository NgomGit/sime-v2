// features/offres/presentation/providers/job_offers_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sime_v2/core/network/network_info.dart';

import '../../domain/entities/job_offer_entity.dart';
import '../../domain/repositories/job_offer_repository.dart';
import '../../providers/offres_providers.dart';

/// État offline-first de la liste des offres d'emploi disponibles.
///
/// Même grammaire que [MySubscriptionsState] : chargement bloquant vs.
/// synchronisation silencieuse (retour de connexion), drapeau hors-ligne pour
/// un bandeau non bloquant, horodatage du dernier rafraîchissement.
class JobOffersState {
  const JobOffersState({
    this.offers = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.isOffline = false,
    this.errorMessage,
    this.lastUpdated,
  });

  final List<JobOfferEntity> offers;
  final bool isLoading;
  final bool isSyncing;
  final bool isOffline;
  final String? errorMessage;
  final DateTime? lastUpdated;

  bool get hasData => offers.isNotEmpty;
  bool get isShowingStaleData => isOffline && hasData;

  JobOffersState copyWith({
    List<JobOfferEntity>? offers,
    bool? isLoading,
    bool? isSyncing,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return JobOffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class JobOffersNotifier extends StateNotifier<JobOffersState> {
  JobOffersNotifier(this._repository, this._networkInfo)
      : super(const JobOffersState());

  final JobOfferRepository _repository;
  final NetworkInfo _networkInfo;

  bool _hasLoadedOnce = false;

  /// Premier chargement, déclenché une seule fois depuis l'écran consommateur.
  void ensureLoaded() {
    if (_hasLoadedOnce || state.isLoading) return;
    loadOffers();
  }

  Future<bool> loadOffers({bool silent = false}) async {
    _hasLoadedOnce = true;
    final offlineAtStart = !(await _networkInfo.isConnected);

    state = state.copyWith(
      isLoading: !silent,
      isSyncing: silent,
      clearError: true,
    );

    final result = await _repository.getAvailableOffers();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          isOffline: offlineAtStart,
          errorMessage: failure.message,
        );
        return false;
      },
      (offers) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          isOffline: offlineAtStart,
          offers: List<JobOfferEntity>.from(offers),
          lastUpdated: DateTime.now(),
          clearError: true,
        );
        return true;
      },
    );
  }
}

/// keepAlive : l'état survit à la navigation (accueil ↔ onglet Offres) et reste
/// disponible pour le calcul des « offres similaires » dans le détail.
final jobOffersNotifierProvider =
    StateNotifierProvider<JobOffersNotifier, JobOffersState>((ref) {
  final repository = ref.watch(jobOfferRepositoryProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final notifier = JobOffersNotifier(repository, networkInfo);

  // Rafraîchit silencieusement sur une vraie reconnexion (hors-ligne → en
  // ligne), pas sur l'émission initiale du stream de connectivité.
  bool? wasConnected;
  ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) {
    final isConnected = next.value;
    if (isConnected == true && wasConnected == false && notifier.mounted) {
      notifier.loadOffers(silent: true);
    }
    if (isConnected != null) wasConnected = isConnected;
  });

  return notifier;
});
