import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dossier/domain/entities/dossier_entity.dart';
import '../../../offres/domain/entities/offre_entity.dart';

// NB : le prochain rendez-vous n'est plus porté par cet état — il vient
// désormais de `rdvNotifierProvider` (features/rendezvous), la même source
// de vérité que l'onglet Agenda, plutôt que d'un mock local dupliqué ici
// (voir dashboard_home_screen.dart, _NextRdvSection).
class DashboardState {
  const DashboardState({
    this.dossier,
    this.recommendedOffres = const [],
    this.isLoading = false,
  });

  final DossierEntity? dossier;
  final List<OffreEntity> recommendedOffres;
  final bool isLoading;

  DashboardState copyWith({
    DossierEntity? dossier,
    List<OffreEntity>? recommendedOffres,
    bool? isLoading,
  }) => DashboardState(
    dossier: dossier ?? this.dossier,
    recommendedOffres: recommendedOffres ?? this.recommendedOffres,
    isLoading: isLoading ?? this.isLoading,
  );
}

class DashboardNotifier extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return DashboardState(
      dossier: const DossierEntity(
        id: 'd001',
        referenceNumber: 'SN-2026-04821',
        serviceType: ServiceType.emploiSalarie,
        status: DossierStatus.enCours,
        currentStep: 3,
        totalSteps: 5,
        conseillerName: 'M. Diallo',
      ),
      recommendedOffres: [
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
      ],
    );
  }
}

final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
