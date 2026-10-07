// features/offres/presentation/providers/offres_detail_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offre_entity.dart';
import '../../providers/offres_providers.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';

import '../mappers/offre_presentation_mapper.dart';
import 'applied_offers_provider.dart';
import 'external_offers_notifier.dart';
import 'job_offers_notifier.dart';
import 'training_offers_notifier.dart';

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

/// Charge le détail d'une offre depuis l'endpoint réel (offline-first, cache
/// par identifiant) et dérive quelques « offres similaires » à partir de la
/// liste déjà chargée en mémoire.
class OffreDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<OffreDetailState, String> {
  @override
  Future<OffreDetailState> build(String offreId) async {
    final resource = decodeOffreId(offreId);

    final OffreEntity offre;
    if (resource.isExternal) {
      // Détail externe : servi depuis la liste déjà chargée en mémoire
      // (aucun endpoint de détail externe confirmé pour l'instant).
      final match = ref
          .read(externalOffersNotifierProvider)
          .offers
          .where((o) => o.id == resource.id);
      if (match.isEmpty) {
        throw Exception(
            'Offre externe indisponible. Rechargez la liste des offres.');
      }
      offre = externalOfferToOffre(match.first);
    } else if (resource.isTraining) {
      final result = await ref
          .read(trainingOfferRepositoryProvider)
          .getOfferDetail(resource.id);
      offre = result.fold(
        (failure) => throw Exception(failure.message),
        trainingOfferToOffre,
      );
    } else {
      final result =
          await ref.read(jobOfferRepositoryProvider).getOfferDetail(resource.id);
      offre = result.fold(
        (failure) => throw Exception(failure.message),
        jobOfferToOffre,
      );
    }

    // Restaure l'état « déjà postulé » depuis le miroir local persistant.
    final alreadyApplied = ref.read(appliedOffersProvider).contains(offreId);

    return OffreDetailState(
      offre: offre,
      similarOffres: _similar(offreId, resource.isTraining),
      hasApplied: alreadyApplied,
    );
  }

  /// Offres du même type déjà en cache mémoire, hors l'offre courante.
  List<OffreEntity> _similar(String currentId, bool isTraining) {
    final List<OffreEntity> pool;
    if (isTraining) {
      pool = ref
          .read(trainingOffersNotifierProvider)
          .offers
          .map(trainingOfferToOffre)
          .toList();
    } else {
      pool = ref
          .read(jobOffersNotifierProvider)
          .offers
          .map(jobOfferToOffre)
          .toList();
    }
    return pool.where((o) => o.id != currentId).take(3).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Sauvegarde locale (optimiste). Aucun endpoint de favoris n'étant fourni,
  /// l'état n'est pas persisté côté serveur pour l'instant.
  void toggleSave() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        offre: current.offre.copyWith(isSaved: !current.offre.isSaved),
      ),
    );
  }

  /// Candidature à l'offre — POST /applicant/api/job-offer-applicants/me.
  ///
  /// Les offres de formation n'exposant pas (encore) d'endpoint de
  /// candidature, on conserve pour elles le marquage local optimiste.
  Future<void> apply() async {
    final current = state.valueOrNull;
    if (current == null || current.isApplying || current.hasApplied) return;

    final resource = decodeOffreId(arg);

    if (resource.isTraining || resource.isExternal) {
      state = AsyncData(current.copyWith(isApplying: true, applyError: null));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      ref.read(appliedOffersProvider.notifier).markApplied(arg);
      state = AsyncData(current.copyWith(isApplying: false, hasApplied: true));
      return;
    }

    final applicantId = ref
        .read(loginNotifierProvider)
        .valueOrNull
        ?.authResponse
        ?.user
        .applicantId;
    if (applicantId == null) {
      state = AsyncData(current.copyWith(
        applyError: 'Session expirée : reconnectez-vous pour postuler.',
      ));
      return;
    }

    state = AsyncData(current.copyWith(isApplying: true, applyError: null));

    final result = await ref.read(jobOfferRepositoryProvider).applyToOffer(
          applicantId: applicantId,
          jobOfferId: resource.id,
        );

    result.fold(
      (failure) => state = AsyncData(
        current.copyWith(isApplying: false, applyError: failure.message),
      ),
      (_) {
        ref.read(appliedOffersProvider.notifier).markApplied(arg);
        state = AsyncData(
          current.copyWith(isApplying: false, hasApplied: true),
        );
      },
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final offreDetailProvider = AutoDisposeAsyncNotifierProviderFamily<
    OffreDetailNotifier, OffreDetailState, String>(
  OffreDetailNotifier.new,
);
