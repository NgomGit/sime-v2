import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/widgets/bullet_list.dart';
import 'package:sime_v2/core/design_system/widgets/s_expandable_text.dart';
import 'package:sime_v2/core/design_system/widgets/s_section.dart';
import 'package:sime_v2/core/design_system/widgets/s_tag.dart';
import 'package:sime_v2/features/offres/presentation/providers/offres_detail_provider.dart';
import 'package:sime_v2/features/offres/presentation/widgets/app_bar.dart';
import 'package:sime_v2/features/offres/presentation/widgets/benefits_grid.dart';
import 'package:sime_v2/features/offres/presentation/widgets/bottom_cta.dart';
import 'package:sime_v2/features/offres/presentation/widgets/company_card.dart';
import 'package:sime_v2/features/offres/presentation/widgets/error_body.dart';
import 'package:sime_v2/features/offres/presentation/widgets/hero_header.dart';
import 'package:sime_v2/features/offres/presentation/widgets/key_info_grid.dart';
import 'package:sime_v2/features/offres/presentation/widgets/recruitement_stepper.dart';
import 'package:sime_v2/features/offres/presentation/widgets/similar_offre.dart';
import 'package:sime_v2/features/offres/presentation/widgets/skeleton.dart';
import 'package:sime_v2/features/offres/presentation/widgets/tags_row.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';

class OffreDetailScreen extends ConsumerWidget {
  const OffreDetailScreen({super.key, required this.offreId});

  final String offreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(offreDetailProvider(offreId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: async.when(
          loading: () => const Skeleton(),
          error: (e, _) => ErrorBody(
            message: e.toString().replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(offreDetailProvider(offreId)),
          ),
          data: (state) => _Body(offreId: offreId, state: state),
        ),
      ),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _Body extends ConsumerWidget {
  const _Body({required this.offreId, required this.state});

  final String offreId;
  final OffreDetailState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(offreDetailProvider(offreId).notifier);
    final offre = state.offre;

    // Remonte les échecs de candidature à l'utilisateur (SnackBar).
    ref.listen(offreDetailProvider(offreId), (prev, next) {
      final err = next.valueOrNull?.applyError;
      final prevErr = prev?.valueOrNull?.applyError;
      if (err != null && err != prevErr) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            OffreDetailAppBar(
              title: offre.title,
              isSaved: offre.isSaved,
              onBack: () => Navigator.of(context).pop(),
              onSave: notifier.toggleSave,
              onShare: () {},
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.sp20,
                AppDimensions.pagePaddingH,
                120,
              ),
              sliver: SliverList.list(children: [
                HeroHeader(offre: offre),
                const SizedBox(height: AppDimensions.sp16),

                TagsRow(offre: offre),
                const SizedBox(height: AppDimensions.sp16),

                KeyInfoGrid(offre: offre),
                const SizedBox(height: AppDimensions.sp24),

                // ── Sommaire (si fourni par l'API) ─────────────────────
                if (offre.summary != null && offre.summary!.trim().isNotEmpty) ...[
                  Section(
                    title: 'Sommaire',
                    child: ExpandableText(text: offre.summary!),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Description ────────────────────────────────────────
                Section(
                  title: 'Description du poste',
                  child: ExpandableText(text: offre.description ?? ''),
                ),
                const SizedBox(height: AppDimensions.sp24),

                // ── Missions ───────────────────────────────────────────
                if (offre.missions.isNotEmpty) ...[
                  Section(
                    title: 'Missions principales',
                    child: BulletList(
                      items: offre.missions,
                      dotColor: AppColors.primary800,
                      dotBg: AppColors.primary100,
                      icon: Icons.arrow_forward_rounded,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Profil recherché ───────────────────────────────────
                if (offre.requirements.isNotEmpty) ...[
                  Section(
                    title: 'Profil recherché',
                    child: BulletList(
                      items: offre.requirements,
                      dotColor: AppColors.secondary800,
                      dotBg: AppColors.secondary100,
                      icon: Icons.check_rounded,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Compétences (offerSkills réelles) ──────────────────
                if (offre.skills.isNotEmpty) ...[
                  Section(
                    title: 'Compétences attendues',
                    child: Wrap(
                      spacing: AppDimensions.sp6,
                      runSpacing: AppDimensions.sp6,
                      children: offre.skills
                          .map((s) => STag(
                                label: s,
                                backgroundColor: AppColors.primary100,
                                textColor: AppColors.primary800,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Ce que nous offrons ────────────────────────────────
                if (offre.benefits.isNotEmpty) ...[
                  Section(
                    title: 'Ce que nous offrons',
                    child: BenefitsGrid(items: offre.benefits),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Processus de recrutement ───────────────────────────
                if (offre.recruitmentSteps.isNotEmpty) ...[
                  Section(
                    title: 'Processus de recrutement',
                    child: RecruitmentStepper(steps: offre.recruitmentSteps),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Structure / employeur ──────────────────────────────
                if (offre.companyDescription != null) ...[
                  CompanyCard(offre: offre),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Offres similaires ──────────────────────────────────
                if (state.similarOffres.isNotEmpty) ...[
                  SimilarSection(
                    offres: state.similarOffres,
                    onTap: (id) => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => OffreDetailScreen(offreId: id),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BottomCta(
            state: state,
            onApply: notifier.apply,
            onSave: notifier.toggleSave,
          ),
        ),
      ],
    );
  }
}
