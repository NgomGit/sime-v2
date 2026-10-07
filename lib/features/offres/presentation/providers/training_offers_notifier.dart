// features/offres/presentation/providers/training_offers_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sime_v2/core/network/network_info.dart';

import '../../domain/entities/training_offer_entity.dart';
import '../../domain/repositories/training_offer_repository.dart';
import '../../providers/offres_providers.dart';

/// État offline-first de la liste des offres de formation disponibles.
/// Miroir de [JobOffersState].
class TrainingOffersState {
  const TrainingOffersState({
    this.offers = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.isOffline = false,
    this.errorMessage,
    this.lastUpdated,
  });

  final List<TrainingOfferEntity> offers;
  final bool isLoading;
  final bool isSyncing;
  final bool isOffline;
  final String? errorMessage;
  final DateTime? lastUpdated;

  bool get hasData => offers.isNotEmpty;
  bool get isShowingStaleData => isOffline && hasData;

  TrainingOffersState copyWith({
    List<TrainingOfferEntity>? offers,
    bool? isLoading,
    bool? isSyncing,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return TrainingOffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class TrainingOffersNotifier extends StateNotifier<TrainingOffersState> {
  TrainingOffersNotifier(this._repository, this._networkInfo)
      : super(const TrainingOffersState());

  final TrainingOfferRepository _repository;
  final NetworkInfo _networkInfo;

  bool _hasLoadedOnce = false;

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
          offers: List<TrainingOfferEntity>.from(offers),
          lastUpdated: DateTime.now(),
          clearError: true,
        );
        return true;
      },
    );
  }
}

final trainingOffersNotifierProvider =
    StateNotifierProvider<TrainingOffersNotifier, TrainingOffersState>((ref) {
  final repository = ref.watch(trainingOfferRepositoryProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final notifier = TrainingOffersNotifier(repository, networkInfo);

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
