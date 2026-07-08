import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/core/design_system/widgets/s_tag.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';

class OffreCard extends StatelessWidget {
  const OffreCard({super.key, required this.offre});
  final OffreEntity offre;

  // Harmonisation des styles basée sur les grands piliers de services de l'ANPEJ
  (Color bg, Color fg, IconData icon) get _typeStyle => switch (offre.type) {
        OffreType.emploi || OffreType.stage => (
            AppColors.primary100, // Fond vert clair
            AppColors.primary400, // Vert ANPEJ
            Icons.work_outline
          ),
        OffreType.formation => (
            AppColors.bleuANPEJBg, // Fond bleu clair
            AppColors.bleuANPEJ, // Bleu ANPEJ
            Icons.school_outlined
          ),
        OffreType.financement => (
            AppColors.accent100, // Fond jaune/orange clair
            AppColors.accent500, // Jaune/Orange ANPEJ
            Icons.rocket_launch_outlined
          ),
        OffreType.migration => (
            AppColors.violetANPEJBg, // Fond violet clair
            AppColors.violetANPEJ, // Violet ANPEJ
            Icons.flight_outlined
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _typeStyle;
    final contractLabel = offre.contractType?.name.toUpperCase();

    return SCard(
      // Si l'offre est "À la une", on applique un fond léger de sa propre couleur thématique
      color: offre.isFeatured ? AppColors.white : AppColors.white,
      borderColor: offre.isFeatured ? fg.withValues(alpha: 0.6) : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge "À la une" contextuel
          if (offre.isFeatured) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sp8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                'À la une',
                style: AppTextStyles.labelXSmall
                    .copyWith(color: fg, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppDimensions.sp10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar de l'offre avec les couleurs du type correspondantes
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: fg, size: AppDimensions.iconLG),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offre.title,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.neutral800),
                    ),
                    const SizedBox(height: AppDimensions.sp4),
                    Row(
                      children: [
                        const Icon(Icons.business_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.neutral400),
                        const SizedBox(width: 4),
                        Text(
                          offre.company,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_outline,
                    color: AppColors.neutral400),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),

          // Tags de métadonnées
          Wrap(
            spacing: AppDimensions.sp4,
            runSpacing: AppDimensions.sp4,
            children: [
              if (contractLabel != null)
                STag(
                    label: contractLabel,
                    backgroundColor: AppColors.neutral50,
                    textColor: AppColors.neutral600),
              STag(
                  label: offre.location,
                  backgroundColor: AppColors.neutral50,
                  textColor: AppColors.neutral600),
              if (offre.educationLevel != null)
                STag(
                    label: offre.educationLevel!,
                    backgroundColor: AppColors.neutral50,
                    textColor: AppColors.neutral600),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.sp12),

          // Actions de l'offre
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: AppDimensions.iconXS, color: AppColors.neutral400),
              const SizedBox(width: 4),
              Text(
                'Clôture ${DateFormat('dd MMM', 'fr').format(offre.deadline)}',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.neutral500),
              ),
              const Spacer(),

              // Bouton secondaire : "Voir l'offre"
              SButton(
                label: 'voir l\'offre',
                onPressed: () =>
                    context.push(AppRoutes.offreDetails, extra: offre.id),
                variant: SButtonVariant.outline,
                fullWidth: false,
                size: SButtonSize.small,
              ),

              const SizedBox(width: 8,),
              // Bouton principal : "Postuler" dynamique selon la couleur dominante de l'offre

              SButton(
                label: 'Postuler', 
                onPressed: () => {},
                fullWidth: false,
                size: SButtonSize.small,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
