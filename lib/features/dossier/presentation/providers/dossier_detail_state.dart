import '../../../dossier/domain/entities/dossier_entity.dart';
import '../../../offres/domain/entities/offre_entity.dart';

// Représente une ligne d'historique (Timeline) de la maquette HTML
class DossierHistoryItem {
  final String title;
  final String subtitle;
  final String date;
  final int type; // 1: Succès/Check, 2: Calendrier, 3: Inscription

  const DossierHistoryItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
  });
}

// État global pour l'écran Mon Dossier
class DossierDetailState {
  final DossierEntity? dossier;
  final List<OffreEntity> candidatures;
  final List<DossierHistoryItem> history;

  const DossierDetailState({
    this.dossier,
    required this.candidatures,
    required this.history,
  });
}