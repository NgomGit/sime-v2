// features/offres/presentation/providers/applied_offers_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';

/// Ensemble persistant des identifiants composites d'offres auxquelles le
/// demandeur a déjà postulé (« job:4 », « training:2 », « external:7 »).
///
/// Persisté localement (Hive) : empêche une nouvelle candidature et alimente
/// le tag « Déjà postulé » de façon stable, y compris après redémarrage de
/// l'app ou hors-ligne. L'API de détail n'exposant pas d'indicateur « déjà
/// postulé », ce miroir local est la source de vérité côté client.
class AppliedOffersNotifier extends Notifier<Set<String>> {
  static const _cacheKey = 'applied_offers';

  @override
  Set<String> build() {
    final raw = ref.read(hiveCacheProvider).get(_cacheKey);
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  bool contains(String offreId) => state.contains(offreId);

  /// Marque une offre comme « postulée » et persiste l'ensemble.
  Future<void> markApplied(String offreId) async {
    if (state.contains(offreId)) return;
    final next = {...state, offreId};
    state = next;
    await ref.read(hiveCacheProvider).put(_cacheKey, next.toList());
  }
}

final appliedOffersProvider =
    NotifierProvider<AppliedOffersNotifier, Set<String>>(
  AppliedOffersNotifier.new,
);
