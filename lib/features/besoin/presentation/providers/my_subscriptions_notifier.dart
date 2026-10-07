// features/besoin/presentation/providers/my_subscriptions_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sime_v2/core/network/network_info.dart';

import '../../domain/entities/my_subscription_entity.dart';
import '../../domain/repositories/besoin_repository.dart';
import '../../providers/besoin_providers.dart';

/// État de la liste « Mes besoins sollicités » — source de vérité unique
/// partagée entre l'accueil (`dashboard_home_screen.dart`) et l'onglet
/// « Candidatures » de Mon dossier (`candidature_tab.dart`).
///
/// Même grammaire offline-first que [RdvState] : chargement bloquant vs.
/// synchronisation silencieuse (retour de connexion), drapeau hors-ligne pour
/// un bandeau non bloquant, et horodatage du dernier rafraîchissement.
class MySubscriptionsState {
  const MySubscriptionsState({
    this.subscriptions = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.isOffline = false,
    this.errorMessage,
    this.lastUpdated,
  });

  final List<MySubscriptionEntity> subscriptions;
  final bool isLoading;
  final bool isSyncing;
  final bool isOffline;
  final String? errorMessage;
  final DateTime? lastUpdated;

  bool get hasData => subscriptions.isNotEmpty;
  bool get isShowingStaleData => isOffline && hasData;

  MySubscriptionsState copyWith({
    List<MySubscriptionEntity>? subscriptions,
    bool? isLoading,
    bool? isSyncing,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return MySubscriptionsState(
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MySubscriptionsNotifier extends StateNotifier<MySubscriptionsState> {
  MySubscriptionsNotifier(this._repository, this._networkInfo)
      : super(const MySubscriptionsState());

  final BesoinRepository _repository;
  final NetworkInfo _networkInfo;

  bool _hasLoadedOnce = false;

  /// Déclenche le premier chargement une seule fois (appelé depuis l'`initState`
  /// des écrans consommateurs). Les rafraîchissements ultérieurs passent par
  /// [loadSubscriptions] (pull-to-refresh, retour de connexion, création d'un
  /// besoin).
  void ensureLoaded() {
    if (_hasLoadedOnce || state.isLoading) return;
    loadSubscriptions();
  }

  Future<bool> loadSubscriptions({bool silent = false}) async {
    _hasLoadedOnce = true;
    final offlineAtStart = !(await _networkInfo.isConnected);

    state = state.copyWith(
      isLoading: !silent,
      isSyncing: silent,
      clearError: true,
    );

    final result = await _repository.getMySubscriptions();

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
      (subscriptions) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          isOffline: offlineAtStart,
          // Recopie dans une vraie List<MySubscriptionEntity> : le repository
          // renvoie en réalité une List<MySubscriptionModel> (retour covariant),
          // et appeler `.reduce`/`.sort` — dont le callback est en position
          // contravariante — sur cette liste remontée en type parent lève une
          // TypeError à l'exécution. La recopie fixe le type réifié de la liste.
          subscriptions: List<MySubscriptionEntity>.from(subscriptions),
          lastUpdated: DateTime.now(),
          clearError: true,
        );
        return true;
      },
    );
  }


  /// Supprime un besoin de façon optimiste : il disparaît aussitôt de la
  /// liste, puis est restauré à sa place si le serveur refuse.
  /// Retourne `(true, null)` ou `(false, message d'erreur)`.
  Future<(bool, String?)> deleteSubscription(int id) async {
    final previous = state.subscriptions;
    final index = previous.indexWhere((s) => s.id == id);
    if (index < 0) return (false, 'Besoin introuvable.');

    state = state.copyWith(
      subscriptions: List<MySubscriptionEntity>.of(previous)..removeAt(index),
      clearError: true,
    );

    final result = await _repository.deleteSubscription(id);
    return result.fold(
      (failure) {
        state = state.copyWith(subscriptions: previous);
        return (false, failure.message);
      },
      (_) {
        // Resynchronise la liste et le cache Hive (sinon le besoin supprimé
        // réapparaîtrait au prochain affichage hors-ligne).
        loadSubscriptions(silent: true);
        return (true, null);
      },
    );
  }
}

/// keepAlive (pas d'autoDispose) : l'état survit à la navigation entre
/// l'accueil et Mon dossier, et reste disponible pour un rafraîchissement
/// immédiat après l'enregistrement d'un nouveau besoin.
final mySubscriptionsNotifierProvider =
    StateNotifierProvider<MySubscriptionsNotifier, MySubscriptionsState>((ref) {
  final repository = ref.watch(besoinRepositoryProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final notifier = MySubscriptionsNotifier(repository, networkInfo);

  // Rafraîchit silencieusement sur une vraie reconnexion (hors-ligne → en
  // ligne), pas sur l'émission initiale du stream de connectivité.
  bool? wasConnected;
  ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) {
    final isConnected = next.value;
    if (isConnected == true && wasConnected == false && notifier.mounted) {
      notifier.loadSubscriptions(silent: true);
    }
    if (isConnected != null) wasConnected = isConnected;
  });

  return notifier;
});
