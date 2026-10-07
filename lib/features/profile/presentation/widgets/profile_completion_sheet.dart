// features/profile/presentation/widgets/profile_completion_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/features/profile/domain/entities/profile_completion.dart';
import 'package:sime_v2/features/profile/presentation/providers/profile_completion_provider.dart';

/// Route d'édition associée à chaque section de profil.
String _routeFor(ProfileSectionKind kind) {
  switch (kind) {
    case ProfileSectionKind.personalInfo:
      return AppRoutes.editIdentityInformations;
    case ProfileSectionKind.personalSituation:
      return AppRoutes.editPersonalSituation;
  }
}

/// Icône représentative de chaque section.
IconData _iconFor(ProfileSectionKind kind) {
  switch (kind) {
    case ProfileSectionKind.personalInfo:
      return Icons.badge_outlined;
    case ProfileSectionKind.personalSituation:
      return Icons.family_restroom_rounded;
  }
}

/// Affiche la feuille modale expliquant, de façon guidée et animée, les
/// sections de profil à compléter avant de pouvoir « Exprimer un besoin ».
///
/// Réactive : elle observe [profileCompletionProvider] et se met à jour en
/// direct au fur et à mesure que l'utilisateur renseigne chaque section, puis
/// propose de poursuivre vers le parcours besoin une fois le profil complet.
Future<void> showProfileCompletionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProfileCompletionSheet(),
  );
}

class _ProfileCompletionSheet extends ConsumerWidget {
  const _ProfileCompletionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(profileCompletionProvider);
    final unlocked = completion.canExpressBesoin;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.sp12,
            AppDimensions.pagePaddingH,
            AppDimensions.sp20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimensions.sp16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? AppColors.primary100
                          : AppColors.secondary100,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      unlocked
                          ? Icons.verified_rounded
                          : Icons.lock_outline_rounded,
                      color: unlocked
                          ? AppColors.primary600
                          : AppColors.secondary800,
                      size: AppDimensions.iconMD,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sp12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unlocked ? 'Profil prêt' : 'Complétez votre profil',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: AppColors.neutral800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          unlocked
                              ? 'Vous pouvez maintenant exprimer un besoin.'
                              : 'Choisissez votre bureau et complétez au moins 75 % du profil.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sp16),

              _CompletionProgress(progress: completion.progress),
              const SizedBox(height: AppDimensions.sp16),

              ...completion.sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sp10),
                  child: _SectionRow(
                    section: section,
                    onTap: () => context.push(_routeFor(section.kind)),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.sp8),

              if (unlocked)
                SButton(
                  label: 'Exprimer un besoin',
                  leadingIcon: Icons.add_rounded,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.nouveauBesoin);
                  },
                )
              else
                SButton(
                  label: 'Plus tard',
                  variant: SButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barre de progression animée (0 → valeur) affichée en tête de la feuille.
class _CompletionProgress extends StatelessWidget {
  const _CompletionProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progression',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.neutral500)),
            Text('${(progress * 100).round()}%',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.secondary800)),
          ],
        ),
        const SizedBox(height: AppDimensions.sp6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.neutral100,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary400),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Ligne cliquable représentant une section, avec son état de complétion et,
/// si incomplète, la liste des champs manquants.
class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section, required this.onTap});

  final ProfileSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final complete = section.isComplete;

    return Material(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sp12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: complete
                      ? AppColors.primary100
                      : AppColors.secondary100,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(section.kind),
                  size: AppDimensions.iconSM,
                  color: complete
                      ? AppColors.primary600
                      : AppColors.secondary600,
                ),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            section.title,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.neutral800),
                          ),
                        ),
                        if (complete)
                          const Icon(Icons.check_circle_rounded,
                              size: AppDimensions.iconSM,
                              color: AppColors.primary600)
                        else
                          Text(
                            '${section.filledCount}/${section.totalCount}',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.neutral400),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sp4),
                    Text(
                      complete
                          ? 'Section complète'
                          : 'À renseigner : ${section.missingLabels.join(', ')}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: complete
                            ? AppColors.primary600
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sp8),
              Icon(
                complete ? Icons.chevron_right : Icons.arrow_forward_rounded,
                size: AppDimensions.iconSM,
                color: complete ? AppColors.neutral300 : AppColors.secondary400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
