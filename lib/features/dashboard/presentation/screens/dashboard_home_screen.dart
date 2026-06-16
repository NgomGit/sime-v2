// dashboard_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/core/design_system/widgets/s_status_badge.dart';
import 'package:sime_v2/core/design_system/widgets/s_tag.dart';
import 'package:sime_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:sime_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:sime_v2/features/dossier/domain/entities/dossier_entity.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';
import 'package:sime_v2/features/rendezvous/domain/entities/rendezvous_entity.dart';

class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key, required this.navigationToProfile});

  final VoidCallback navigationToProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).valueOrNull;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _TopBar(
              navigationToProfile: navigationToProfile,
              firstName: user?.firstName ?? 'Mamadou',
              initials: user?.initials ?? 'MA',
            ),
          ),
          dashboardAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary800, // marron institutionnel
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Erreur : $e',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ),
            ),
            data: (state) => SliverPadding(
              padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
              sliver: SliverList.list(
                children: [
                  if (state.dossier != null)
                    _DossierStatusCard(dossier: state.dossier!),
                  const SizedBox(height: AppDimensions.sp16),
                  if (state.upcomingRdv != null)
                    _NextRdvCard(rdv: state.upcomingRdv!),
                  const SizedBox(height: AppDimensions.sp16),
                  _OffresSection(offres: state.recommendedOffres),
                  const SizedBox(height: AppDimensions.sp48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.firstName,
    required this.initials,
    required this.navigationToProfile,
  });

  final String firstName, initials;
  final VoidCallback navigationToProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp20,
        vertical: AppDimensions.sp14,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: navigationToProfile,
                child: Text('Bonjour 👋',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral400,
                    )),
              ),
              Text(firstName, style: AppTextStyles.headingSmall),
            ],
          ),
          const Spacer(),
          // Cloche de notification — fond marron très doux, point rouge d'alerte
          Stack(
            children: [
              Container(
                width: AppDimensions.avatarMD,
                height: AppDimensions.avatarMD,
                decoration: BoxDecoration(
                  // secondary100 : fond institutionnel doux — la cloche appartient à l'ANPEJ
                  color: AppColors.secondary100,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                alignment: Alignment.center,
                child: IconButton(
                  // size: AppDimensions.iconMD,
                  color: AppColors.secondary800,
                  onPressed: () {
                    context.push(AppRoutes.notification);
                  },
                  icon: const Icon(Icons
                      .notifications_outlined), // icône marron institutionnel
                ),
              ),
              // Badge d'alerte — erreur rouge, inchangé (sémantique universelle)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dossier status card (dark)
// ─────────────────────────────────────────────────────────────────────────────
class _DossierStatusCard extends StatelessWidget {
  const _DossierStatusCard({required this.dossier});

  final DossierEntity dossier;

  String get _serviceLabel => switch (dossier.serviceType) {
        ServiceType.emploiSalarie => 'Emploi salarié',
        ServiceType.financement => 'Financement',
        ServiceType.formation => 'Formation',
        ServiceType.mobiliteInt => 'Mobilité internationale',
        ServiceType.agrijeunes => 'Agrijeunes',
      };

  @override
  Widget build(BuildContext context) {
    return SCard(
      // isDark: true → darkSurfaceCard (#1A2412), cohérent avec l'onboarding
      isDark: true,
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SStatusBadge(label: 'En traitement'),
              const Spacer(),
              Text(
                '#${dossier.referenceNumber}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.darkTextHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          Text(
            'Dossier $_serviceLabel',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          Text(
            'Pôle Formation-Insertion · Dakar',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.sp16),

          // Ligne progression
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.darkTextHint,
                ),
              ),
              // Pourcentage en vert ANPEJ — la progression = avenir positif
              Text(
                '${dossier.progressPercent}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp6),

          // Barre de progression — vert ANPEJ sur fond sombre translucide
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: dossier.progressRatio,
              minHeight: 4,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary400, // vert ANPEJ
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sp8),

          // Segments d'étapes :
          //   passées   → vert ANPEJ (accompli = positif)
          //   courante  → jaune ANPEJ (en cours = attention / urgence douce)
          //   futures   → blanc 10% (non encore atteint)
          Row(
            children: List.generate(dossier.totalSteps, (i) {
              final Color c;
              if (i < dossier.currentStep - 1) {
                c = AppColors.primary400; // vert : étape passée
              } else if (i == dossier.currentStep - 1) {
                c = AppColors.accent500; // jaune : étape en cours
              } else {
                c = Colors.white.withAlpha(25); // neutre : étape future
              }
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimensions.sp6),
          Text(
            'Étape ${dossier.currentStep} sur ${dossier.totalSteps} · Entretien conseiller',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.darkTextHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prochain RDV
// ─────────────────────────────────────────────────────────────────────────────
class _NextRdvCard extends StatelessWidget {
  const _NextRdvCard({required this.rdv});

  final RendezVousEntity rdv;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prochain rendez-vous',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.neutral800,
              ),
            ),
            // "Voir tout" — lien vert (action disponible = positif)
            Text(
              'Voir tout',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp10),
        SCard(
          child: Row(
            children: [
              // Bloc date — fond secondary100 (marron doux) + texte marron
              // La date d'un RDV institutionnel porte la couleur de l'institution
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sp10,
                  vertical: AppDimensions.sp8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary100,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(rdv.dateTime),
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors
                            .secondary800, // jour en marron institutionnel
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'fr')
                          .format(rdv.dateTime)
                          .toUpperCase(),
                      style: AppTextStyles.labelXSmall.copyWith(
                        color: AppColors.secondary600, // mois en marron moyen
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entretien — ${rdv.conseillerName}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: AppDimensions.iconXS,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${DateFormat('HH\'h\'mm').format(rdv.dateTime)} · ${rdv.location}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sp6),
                    const SStatusBadge(label: 'Confirmé'),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.neutral200,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section offres
// ─────────────────────────────────────────────────────────────────────────────
class _OffresSection extends StatelessWidget {
  const _OffresSection({required this.offres});

  final List<OffreEntity> offres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Offres pour vous',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.neutral800,
              ),
            ),
            // "Voir tout" — lien vert (opportunité = positif)
            Text(
              'Voir tout',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp10),
        ...offres.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sp8),
            child: _OffreItem(offre: o),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item offre
// ─────────────────────────────────────────────────────────────────────────────
class _OffreItem extends StatelessWidget {
  const _OffreItem({required this.offre});

  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    return SCard(
      child: Row(
        children: [
          // Icône emploi — fond vert doux + icône vert sombre
          // L'offre d'emploi = opportunité = univers vert
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.work_outline,
              color: AppColors.primary800,
              size: AppDimensions.iconMD,
            ),
          ),
          const SizedBox(width: AppDimensions.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offre.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.neutral800,
                  ),
                ),
                Text(
                  offre.company,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppDimensions.sp6),
                Wrap(
                  spacing: AppDimensions.sp4,
                  children: [
                    // Tag contrat — fond vert doux, texte vert sombre
                    if (offre.contractType != null)
                      STag(
                        label: offre.contractType!.name.toUpperCase(),
                        backgroundColor: AppColors.primary100,
                        textColor: AppColors.primary800,
                      ),
                    // Tag lieu — fond neutre chaud, texte neutre
                    STag(
                      label: offre.location,
                      backgroundColor: AppColors.neutral50,
                      textColor: AppColors.neutral600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Point "À la une" — accent500 (jaune ANPEJ) remplace error (rouge)
          // Une offre mise en avant = opportunité prioritaire, pas une erreur
          if (offre.isFeatured)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.accent500, // jaune ANPEJ
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
