// features/reclamation/presentation/providers/reclamations_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/network/network_info.dart';

import '../../domain/entities/reclamation_entity.dart';
import '../../domain/repositories/reclamation_repository.dart';
import '../../providers/reclamation_providers.dart';

/// État de la liste « Mes réclamations ».
///
/// Même grammaire offline-first que [RdvState]/[MySubscriptionsState] :
/// chargement bloquant vs. synchronisation silencieuse (retour de connexion),
/// drapeau hors-ligne pour un bandeau non bloquant, horodatage du dernier
/// rafraîchissement. [pendingClaims] = nouvelles réclamations créées hors-ligne
/// pas encore synchronisées (affichées en tête, en « cours d'envoi »).
class ReclamationsState {
  final List<ClaimRequestEntity> claims;
  final List<ClaimMessageEntity> pendingClaims;
  final bool isLoading;
  final bool isSyncing;
  final bool isOffline;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const ReclamationsState({
    this.claims = const [],
    this.pendingClaims = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.isOffline = false,
    this.errorMessage,
    this.lastUpdated,
  });

  bool get hasData => claims.isNotEmpty || pendingClaims.isNotEmpty;
  bool get isShowingStaleData => isOffline && claims.isNotEmpty;

  /// Réclamations triées, plus récentes d'abord (id décroissant — l'API
  /// n'expose pas de date de création).
  List<ClaimRequestEntity> get sortedClaims {
    final list = List<ClaimRequestEntity>.from(claims)
      ..sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  int get openCount =>
      claims.where((c) => c.status != ClaimStatus.closed).length;

  ReclamationsState copyWith({
    List<ClaimRequestEntity>? claims,
    List<ClaimMessageEntity>? pendingClaims,
    bool? isLoading,
    bool? isSyncing,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return ReclamationsState(
      claims: claims ?? this.claims,
      pendingClaims: pendingClaims ?? this.pendingClaims,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ReclamationsNotifier extends StateNotifier<ReclamationsState> {
  ReclamationsNotifier(this._repository, this._networkInfo)
      : super(const ReclamationsState());

  final ReclamationRepository _repository;
  final NetworkInfo _networkInfo;

  bool _hasLoadedOnce = false;

  /// Premier chargement, une seule fois (appelé depuis l'`initState` de
  /// l'écran). Les rafraîchissements ultérieurs passent par [loadClaims].
  void ensureLoaded() {
    if (_hasLoadedOnce || state.isLoading) return;
    loadClaims();
  }

  Future<bool> loadClaims({bool silent = false}) async {
    _hasLoadedOnce = true;
    final offlineAtStart = !(await _networkInfo.isConnected);

    state = state.copyWith(
      isLoading: !silent,
      isSyncing: silent,
      clearError: true,
    );

    final result = await _repository.getMyClaims();
    final pending = await _repository.pendingNewClaims();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          isOffline: offlineAtStart,
          pendingClaims: pending,
          errorMessage: failure.message,
        );
        return false;
      },
      (claims) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          isOffline: offlineAtStart,
          // Recopie explicite (retour covariant List<ClaimRequestModel>) pour
          // éviter la TypeError au `.sort` — voir la note dans
          // MySubscriptionsNotifier.loadSubscriptions.
          claims: List<ClaimRequestEntity>.from(claims),
          pendingClaims: pending,
          lastUpdated: DateTime.now(),
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Crée une nouvelle réclamation puis rafraîchit silencieusement la liste.
  /// Retourne l'issue (envoyée / mise en file) ou `null` en cas d'échec dur.
  Future<ClaimSendOutcome?> createClaim({
    required String message,
    required int applicantId,
  }) async {
    final result = await _repository.createClaim(
      message: message,
      applicantId: applicantId,
    );
    final outcome = result.fold<ClaimSendOutcome?>(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (o) => o,
    );
    if (outcome != null) {
      await loadClaims(silent: true);
    }
    return outcome;
  }

  /// Réessaie manuellement d'acheminer la file d'attente hors-ligne
  /// (réclamations + réponses en attente). Déclenché par le bouton « Réessayer
  /// l'envoi » des cartes en attente, une fois la connexion revenue.
  ///
  /// Retourne `false` si toujours hors-ligne (rien tenté), `true` sinon.
  Future<bool> retryPendingSubmissions() async {
    if (!(await _networkInfo.isConnected)) {
      state = state.copyWith(
        isOffline: true,
        errorMessage:
            'Toujours hors-ligne : la réclamation sera transmise au retour de la connexion.',
      );
      return false;
    }
    state = state.copyWith(isSyncing: true, clearError: true);
    await _repository.synchronizeOfflineData();
    // Recharge en silencieux : l'outbox vidé fait disparaître les cartes
    // « en attente » et rafraîchit la liste serveur.
    await loadClaims(silent: true);
    return true;
  }
}

final reclamationsNotifierProvider =
    StateNotifierProvider<ReclamationsNotifier, ReclamationsState>((ref) {
  final repository = ref.watch(reclamationRepositoryProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final notifier = ReclamationsNotifier(repository, networkInfo);

  // Rejoue la file d'attente puis rafraîchit silencieusement sur une vraie
  // reconnexion (hors-ligne → en ligne), pas sur l'émission initiale.
  bool? wasConnected;
  ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) async {
    final isConnected = next.value;
    if (isConnected == true && wasConnected == false && notifier.mounted) {
      await repository.synchronizeOfflineData();
      notifier.loadClaims(silent: true);
    }
    if (isConnected != null) wasConnected = isConnected;
  });

  return notifier;
});
