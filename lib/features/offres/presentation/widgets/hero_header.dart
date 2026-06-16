import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key, required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo d'entreprise institutionnel
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.business_outlined,
              size: AppDimensions.iconXL, color: AppColors.neutral500),
        ),
        const SizedBox(width: AppDimensions.sp14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CORRECTION : Badge À la une harmonisé sur la charte (Vert doux/foncé)
              if (offre.isFeatured) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sp8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    'À la une',
                    style: AppTextStyles.labelXSmall.copyWith(
                        color: AppColors.primary800,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: AppDimensions.sp6),
              ],
              Text(offre.title,
                  style: AppTextStyles.headingMedium
                      .copyWith(color: AppColors.neutral800)),
              const SizedBox(height: AppDimensions.sp6),
              Row(children: [
                const Icon(Icons.business_outlined,
                    size: AppDimensions.iconXS, color: AppColors.neutral400),
                const SizedBox(width: 4),
                Text(offre.company,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.neutral600)),
                const SizedBox(width: AppDimensions.sp6),
                _Dot(),
                const SizedBox(width: AppDimensions.sp6),
                const Icon(Icons.location_on_outlined,
                    size: AppDimensions.iconXS, color: AppColors.neutral400),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(offre.location,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.neutral600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: AppDimensions.sp8),
              Row(children: [
                const Icon(Icons.group_outlined,
                    size: AppDimensions.iconXS, color: AppColors.neutral400),
                const SizedBox(width: 4),
                Text('${offre.applicantCount} candidatures',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral500)),
                if (offre.referenceNumber != null) ...[
                  const SizedBox(width: AppDimensions.sp10),
                  _Dot(),
                  const SizedBox(width: AppDimensions.sp6),
                  Text('Réf: ${offre.referenceNumber}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.neutral500)),
                ],
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
            color: AppColors.neutral300, shape: BoxShape.circle),
      );
}
