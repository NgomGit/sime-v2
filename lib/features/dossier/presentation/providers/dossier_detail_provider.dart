import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dossier_entity.dart';
import '../../../offres/domain/entities/offre_entity.dart';
import 'dossier_detail_state.dart';

final dossierDetailProvider =
    AsyncNotifierProvider<DossierDetailNotifier, DossierDetailState>(() {
  return DossierDetailNotifier();
});

class DossierDetailNotifier extends AsyncNotifier<DossierDetailState> {
  @override
  Future<DossierDetailState> build() async {
    // Simulation d'une récupération de données (Mock fidèle à l'écran 6)
    await Future.delayed(const Duration(milliseconds: 500));

    const mockDossier = DossierEntity(
      referenceNumber: 'SN-2026-04821',
      serviceType: ServiceType.emploiSalarie,
      currentStep: 3,
      totalSteps: 5,
      id: '',
      status: DossierStatus.enCours,
    );

    // Mock Candidatures (Wave & 3FPT)
    final mockCandidatures = [
      OffreEntity(
        id: 'c_01',
        title: 'Développeur Mobile Flutter',
        company: 'Wave Mobile Money · Dakar',
        location: 'Dakar',
        isFeatured: true,
        deadline: DateTime(2026, 06, 15),
        contractType:
            ContractType.cdi, // Supposant un enum ContractType ou équivalent
        educationLevel: 'Bac+4',
        type: OffreType.emploi,
      ),
      OffreEntity(
        id: 'c_02',
        title: 'Formation courte durée 3FPT',
        company: '3FPT · National',
        location: 'National',
        isFeatured: false,
        deadline: DateTime(2026, 06, 01),
        contractType: null,
        educationLevel: '6 semaines', // Utilisé temporairement ici
        type: OffreType.formation,
      ),
    ];

    final mockHistory = [
      const DossierHistoryItem(
        title: 'Dossier transmis au partenaire',
        subtitle: 'Routage automatique · DER / FJ',
        date: '20 mai',
        type: 4, // Ex: Type Financement / Partenaire extérieur
      ),
      const DossierHistoryItem(
        title: 'Avis du comité de validation',
        subtitle: 'Accepté pour incubation · Pôle Auto-emploi',
        date: '19 mai',
        type: 1, // Validation / Statut positif
      ),
      const DossierHistoryItem(
        title: 'Dossier validé par conseiller',
        subtitle: 'M. Diallo · Bureau Plateau',
        date: '14 mai',
        type: 1,
      ),
      const DossierHistoryItem(
        title: 'Entretien de diagnostic réalisé',
        subtitle: 'Orientation : Profil Entrepreneur',
        date: '14 mai',
        type: 2, // Rendez-vous / Entretien passé
      ),
      const DossierHistoryItem(
        title: 'Rendez-vous confirmé',
        subtitle: '18 mai · 10h30',
        date: '12 mai',
        type: 2,
      ),
      const DossierHistoryItem(
        title: 'Demande de pièce complémentaire',
        subtitle: 'Copie certifiée du diplôme manquante',
        date: '8 mai',
        type: 5, // Ex: Alerte / Action requise du jeune
      ),
      const DossierHistoryItem(
        title: 'Aiguillage vers service Migration',
        subtitle: 'Étude de profil · Pôle CSAEM / Mobilité',
        date: '5 mai',
        type: 4, // Routage interne / Pôle spécialisé
      ),
      const DossierHistoryItem(
        title: 'Inscription complétée',
        subtitle: 'Étape 3 finalisée',
        date: '2 mai',
        type: 3, // Création de compte / Initialisation
      ),
    ];

    return DossierDetailState(
      dossier: mockDossier,
      candidatures: mockCandidatures,
      history: mockHistory,
    );
  }
}
