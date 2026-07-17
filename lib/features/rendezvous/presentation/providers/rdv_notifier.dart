// features/rendezvous/presentation/providers/rdv_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/features/rendezvous/domain/entities/rdv_entity.dart';
import 'package:sime_v2/features/rendezvous/domain/repositories/rdv_repository.dart';
import 'package:sime_v2/features/rendezvous/providers/rendezvous_providers.dart';

/// État exposé par [RdvNotifier] à l'écran Agenda.
///
///  • [isLoading]    → premier chargement ou pull-to-refresh manuel : l'UI
///                     peut bloquer/afficher un skeleton.
///  • [isSyncing]    → rafraîchissement silencieux en arrière-plan
///                     (déclenché au retour de connexion) : ne doit jamais
///                     bloquer l'UI, juste afficher un indicateur discret.
///  • [isOffline]    → la dernière tentative de chargement s'est faite sans
///                     connexion (donnée servie depuis le cache Hive par
///                     `OfflineFirstMixin.offlineFirst`, voir
///                     `RdvRepositoryImpl.getMyRdvs`).
///  • [lastUpdated]  → horodatage du dernier chargement réussi (cache ou
///                     réseau), pour afficher "Mis à jour à l'instant".
class RdvState {
  final List<RdvEntity> rdvs;
  final bool isLoading;
  final bool isSyncing;
  final bool isOffline;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const RdvState({
    this.rdvs = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.isOffline = false,
    this.errorMessage,
    this.lastUpdated,
  });

  bool get hasData => rdvs.isNotEmpty;

  /// Les données affichées proviennent du cache hors-ligne plutôt que d'un
  /// aller-retour réseau frais à l'instant — sert à afficher un bandeau
  /// non bloquant plutôt qu'un écran d'erreur, puisqu'on a quand même
  /// quelque chose à montrer.
  bool get isShowingStaleData => isOffline && hasData;

  List<RdvEntity> get upcoming {
    final list = rdvs.where((r) => r.isUpcoming).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    return list;
  }

  List<RdvEntity> get past {
    final list = rdvs.where((r) => r.isPast).toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return list;
  }

  RdvState copyWith({
    List<RdvEntity>? rdvs,
    bool? isLoading,
    bool? isSyncing,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return RdvState(
      rdvs: rdvs ?? this.rdvs,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class RdvNotifier extends StateNotifier<RdvState> {
  final RdvRepository _repository;
  final NetworkInfo _networkInfo;

  RdvNotifier(this._repository, this._networkInfo) : super(const RdvState());

  /// Charge la liste des rendez-vous.
  ///
  /// [silent] : true pour un rafraîchissement en arrière-plan (retour de
  /// connexion) qui ne doit pas afficher de loader bloquant — seul
  /// [RdvState.isSyncing] passe à true dans ce cas.
  Future<bool> loadRdvs({bool silent = false}) async {
    // Capturé AVANT l'appel réseau : `offlineFirst` retombe silencieusement
    // sur le cache en cas d'échec réseau et renvoie quand même `Right(...)`,
    // donc on ne peut pas déduire "donnée fraîche vs. mise en cache" du seul
    // résultat — on note l'état de connectivité au moment de la tentative.
    final offlineAtStart = !(await _networkInfo.isConnected);

    state = state.copyWith(
      isLoading: !silent,
      isSyncing: silent,
      clearError: true,
    );

    final result = await _repository.getMyRdvs();

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
      (rdvs) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          isOffline: offlineAtStart,
          rdvs: rdvs,
          lastUpdated: DateTime.now(),
          clearError: true,
        );
        return true;
      },
    );
  }
}

final rdvNotifierProvider = StateNotifierProvider<RdvNotifier, RdvState>((ref) {
  final repository = ref.watch(rdvRepositoryProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final notifier = RdvNotifier(repository, networkInfo);

  // Rafraîchit silencieusement l'agenda sur une vraie reconnexion (transition
  // hors-ligne → en ligne), pas sur l'émission initiale du stream (qui se
  // déclencherait dès la création du provider et ferait doublon avec le
  // chargement explicite déclenché par l'écran dans son `initState`).
  bool? wasConnected;
  ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) {
    final isConnected = next.value;
    if (isConnected == true && wasConnected == false) {
      notifier.loadRdvs(silent: true);
    }
    if (isConnected != null) wasConnected = isConnected;
  });

  return notifier;
});
