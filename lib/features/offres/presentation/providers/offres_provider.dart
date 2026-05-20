import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/offre_entity.dart';

final _allOffres = [
  OffreEntity(
    id: 'o001',
    title: 'Développeur Mobile Flutter',
    company: 'Wave Mobile Money',
    location: 'Dakar',
    type: OffreType.emploi,
    contractType: ContractType.cdi,
    deadline: DateTime.now().add(const Duration(days: 15)),
    educationLevel: 'Bac+4',
    isFeatured: true,
  ),
  OffreEntity(
    id: 'o002',
    title: 'Agent terrain Agrijeunes',
    company: 'Agrijeunes Sénégal',
    location: 'Thiès',
    type: OffreType.emploi,
    contractType: ContractType.cdd,
    deadline: DateTime.now().add(const Duration(days: 10)),
  ),
  OffreEntity(
    id: 'o003',
    title: 'Formation courte durée 3FPT',
    company: '3FPT · National',
    location: 'National',
    type: OffreType.formation,
    deadline: DateTime.now().add(const Duration(days: 5)),
  ),
  OffreEntity(
    id: 'o004',
    title: 'Développeur Full Stack',
    company: 'Orange Sénégal',
    location: 'Dakar',
    type: OffreType.emploi,
    contractType: ContractType.cdi,
    deadline: DateTime.now().add(const Duration(days: 30)),
    educationLevel: 'Bac+3',
  ),
  OffreEntity(
    id: 'o005',
    title: 'Formateur certifié FORCEN',
    company: 'FORCEN',
    location: 'Saint-Louis',
    type: OffreType.formation,
    deadline: DateTime.now().add(const Duration(days: 20)),
  ),

  // ── AJOUT DES OFFRES DE TYPE MIGRATION (SIME V2 - CSAEM) ──────────────────
  OffreEntity(
    id: 'o006',
    title: 'Accompagnement et Mobilité Professionnelle Internationale',
    company: 'CSAEM · ANPEJ',
    location: 'Dakar (Pôle Migration)',
    type: OffreType.migration,
    deadline: DateTime.now().add(const Duration(days: 45)),
    educationLevel: 'Tous niveaux',
    isFeatured: true,
  ),
  OffreEntity(
    id: 'o007',
    title: 'Technicien de Maintenance Industrielle (Contrat International)',
    company: 'CSAEM · Partenaire International',
    location: 'International', // Prise en charge de la mobilité internationale
    type: OffreType.migration,
    contractType:
        ContractType.cdd, // Souvent des contrats à durée déterminée au départ
    deadline: DateTime.now().add(const Duration(days: 25)),
    educationLevel: 'Bac+2 / BT',
  ),
];

class OffresFilter {
  const OffresFilter({this.type, this.query = ''});
  final OffreType? type;
  final String query;
}

final offresFilterProvider =
    StateProvider<OffresFilter>((ref) => const OffresFilter());

final offresListProvider = Provider<AsyncValue<List<OffreEntity>>>((ref) {
  final filter = ref.watch(offresFilterProvider);
  var list = _allOffres;
  if (filter.type != null) {
    list = list.where((o) => o.type == filter.type).toList();
  }
  if (filter.query.isNotEmpty) {
    final q = filter.query.toLowerCase();
    list = list
        .where(
          (o) =>
              o.title.toLowerCase().contains(q) ||
              o.company.toLowerCase().contains(q) ||
              o.location.toLowerCase().contains(q),
        )
        .toList();
  }
  return AsyncData(list);
});
