import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offre_entity.dart';
// import '../../domain/usecases/apply_usecase.dart';
// import '../../domain/usecases/get_offre_detail_usecase.dart';
// import '../../domain/usecases/get_similar_offres_usecase.dart';
// import '../../domain/usecases/toggle_save_usecase.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class OffreDetailState {
  const OffreDetailState({
    required this.offre,
    this.similarOffres = const [],
    this.isApplying = false,
    this.hasApplied = false,
    this.applyError,
  });

  final OffreEntity offre;
  final List<OffreEntity> similarOffres;
  final bool isApplying;
  final bool hasApplied;
  final String? applyError;

  OffreDetailState copyWith({
    OffreEntity? offre,
    List<OffreEntity>? similarOffres,
    bool? isApplying,
    bool? hasApplied,
    String? applyError,
  }) =>
      OffreDetailState(
        offre: offre ?? this.offre,
        similarOffres: similarOffres ?? this.similarOffres,
        isApplying: isApplying ?? this.isApplying,
        hasApplied: hasApplied ?? this.hasApplied,
        applyError: applyError,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class OffreDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<OffreDetailState, String> {
  @override
  Future<OffreDetailState> build(String offreId) async {
    // Inject use cases — in production wire through a DI provider
    // e.g. ref.watch(getOffreDetailUseCaseProvider)
    await Future.delayed(const Duration(milliseconds: 700));

    // ── Stub data (replace with real use case calls) ──────────────────────
    final offre = _stubOffre(offreId);
    final similar = _stubSimilar();
    return OffreDetailState(offre: offre, similarOffres: similar);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> toggleSave() async {
    final current = state.valueOrNull;
    if (current == null) return;
    // Optimistic update
    state = AsyncData(
      current.copyWith(
        offre: current.offre.copyWith(isSaved: !current.offre.isSaved),
      ),
    );
    // TODO: call _toggleSave.call(current.offre.id) and handle Left
  }

  Future<void> apply() async {
    final current = state.valueOrNull;
    if (current == null || current.isApplying || current.hasApplied) return;

    state = AsyncData(current.copyWith(isApplying: true, applyError: null));

    await Future.delayed(const Duration(milliseconds: 1000)); // stub

    // TODO: call _apply.call(offre.id) and fold Left/Right
    state = AsyncData(
      current.copyWith(isApplying: false, hasApplied: true),
    );
  }

  // ── Stub helpers ──────────────────────────────────────────────────────────

  static OffreEntity _stubOffre(String id) => OffreEntity(
        id: id,
        title: 'Développeur Mobile Flutter Senior',
        company: 'Wave Mobile Money',
        location: 'Dakar, Almadies',
        type: OffreType.emploi,
        contractType: ContractType.cdi,
        level: OffreLevel.national,
        deadline: DateTime(2026, 5, 30),
        educationLevel: 'Bac+4 / Master',
        experienceYears: '2–4 ans',
        applicantCount: 47,
        isFeatured: true,
        sector: 'Fintech / Mobile',
        companySize: '200–500 employés',
        referenceNumber: 'WAVE-2026-MOB-012',
        publishedAt: DateTime(2026, 4, 28),
        description:
            'Wave Mobile Money recherche un développeur Flutter expérimenté '
            'pour renforcer son équipe mobile. Vous travaillerez sur des '
            'produits à fort impact utilisés par des millions de personnes '
            'au Sénégal et dans toute l\'Afrique de l\'Ouest.',
        companyDescription:
            'Wave est le leader du mobile money en Afrique de l\'Ouest, '
            'opérant au Sénégal, Côte d\'Ivoire, Ouganda et Zambie avec '
            'plus de 10 millions d\'utilisateurs actifs.',
        missions: const [
          'Développer et maintenir les apps iOS et Android avec Flutter/Dart',
          'Implémenter des fonctionnalités de paiement mobile sécurisées',
          'Collaborer avec les équipes design, backend et QA',
          'Contribuer aux revues de code et à l\'amélioration continue',
          'Participer aux sessions de planification et de sprint',
        ],
        requirements: const [
          'Bac+4 minimum en Informatique ou Génie Logiciel',
          '2 à 4 ans d\'expérience en développement Flutter/Dart',
          'Maîtrise de l\'état management : Riverpod, Bloc',
          'Expérience avec les API REST, WebSocket et GraphQL',
          'Bonne pratique des tests unitaires et d\'intégration',
          'Bon niveau de français et d\'anglais technique',
        ],
        benefits: const [
          'Salaire compétitif selon profil + primes performance',
          'Assurance santé famille complète',
          'MacBook Pro dernière génération fourni',
          'Télétravail partiel (2 jours/semaine)',
          'Budget formation annuel de 500 000 FCFA',
        ],
        recruitmentSteps: const [
          'Candidature via SIME',
          'Entretien conseiller ANPEJ',
          'Test technique Flutter (2h)',
          'Entretien RH + tech Wave',
          'Décision finale sous 15 jours',
        ],
      );

  static List<OffreEntity> _stubSimilar() => [
        OffreEntity(
          id: 'sim_001',
          title: 'Développeur Flutter Junior',
          company: 'Orange Sénégal',
          location: 'Dakar',
          type: OffreType.emploi,
          contractType: ContractType.cdd,
          deadline: DateTime(2026, 6, 15),
          educationLevel: 'Bac+3',
        ),
        OffreEntity(
          id: 'sim_002',
          title: 'Lead Mobile iOS / Android',
          company: 'Free Sénégal',
          location: 'Dakar',
          type: OffreType.emploi,
          contractType: ContractType.cdi,
          deadline: DateTime(2026, 6, 10),
          educationLevel: 'Bac+5',
        ),
        OffreEntity(
          id: 'sim_003',
          title: 'Ingénieur Full Stack React/Node',
          company: 'Expresso',
          location: 'Dakar',
          type: OffreType.emploi,
          contractType: ContractType.cdi,
          deadline: DateTime(2026, 6, 20),
          educationLevel: 'Bac+4',
        ),
      ];
}

// ── Provider ──────────────────────────────────────────────────────────────────

final offreDetailProvider =
    AutoDisposeAsyncNotifierProviderFamily<OffreDetailNotifier, OffreDetailState, String>(
  OffreDetailNotifier.new,
);
