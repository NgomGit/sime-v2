// features/offres/presentation/providers/offres_provider.dart
//
// Liste unifiée « Offres » (emploi + formation) dérivée des notifiers
// offline-first, mappée vers le modèle de présentation [OffreEntity] et filtrée
// par type / recherche texte. Les drapeaux de chargement / hors-ligne / sync
// restent lus directement sur les notifiers par l'écran (bandeau de statut).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offre_entity.dart';
import '../mappers/offre_presentation_mapper.dart';
import 'external_offers_notifier.dart';
import 'job_offers_notifier.dart';
import 'training_offers_notifier.dart';

class OffresFilter {
  const OffresFilter({this.type, this.query = ''});
  final OffreType? type;
  final String query;

  OffresFilter copyWith({OffreType? type, String? query, bool clearType = false}) =>
      OffresFilter(
        type: clearType ? null : (type ?? this.type),
        query: query ?? this.query,
      );
}

final offresFilterProvider =
    StateProvider<OffresFilter>((ref) => const OffresFilter());

/// Liste complète (emploi + formation), mappée puis filtrée.
final offresListProvider = Provider<List<OffreEntity>>((ref) {
  final jobs =
      ref.watch(jobOffersNotifierProvider).offers.map(jobOfferToOffre);
  final trainings = ref
      .watch(trainingOffersNotifierProvider)
      .offers
      .map(trainingOfferToOffre);
  final externals = ref
      .watch(externalOffersNotifierProvider)
      .offers
      .map(externalOfferToOffre);
  final filter = ref.watch(offresFilterProvider);

  var list = <OffreEntity>[...jobs, ...trainings, ...externals];

  if (filter.type != null) {
    list = list.where((o) => o.type == filter.type).toList();
  }

  final q = filter.query.trim().toLowerCase();
  if (q.isNotEmpty) {
    list = list
        .where((o) =>
            o.title.toLowerCase().contains(q) ||
            o.company.toLowerCase().contains(q) ||
            o.location.toLowerCase().contains(q))
        .toList();
  }

  return list;
});
