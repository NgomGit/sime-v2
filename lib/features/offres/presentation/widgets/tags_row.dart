// ─── Tags row ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_tag.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';

class TagsRow extends StatelessWidget {
  const TagsRow({super.key, required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.sp6,
      runSpacing: AppDimensions.sp6,
      children: [
        if (offre.contractType != null)
          STag(
            label: offre.contractType!.name.toUpperCase(),
            backgroundColor: AppColors.primary100,
            textColor: AppColors.primary800,
          ),
        if (offre.educationLevel != null)
          STag(
            label: offre.educationLevel!,
            backgroundColor: AppColors.neutral50,
            textColor: AppColors.neutral600,
          ),
        if (offre.experienceYears != null)
          STag(
            label: offre.experienceYears!,
            backgroundColor: AppColors.neutral50,
            textColor: AppColors.neutral600,
          ),
        if (offre.sector != null)
          STag(
            label: offre.sector!,
            backgroundColor: AppColors.secondary100, // Marron institutionnel très léger
            textColor: AppColors.secondary800,
          ),
        
        // Deadline chip avec code couleur d'urgence propre
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sp8, vertical: AppDimensions.sp4),
          decoration: BoxDecoration(
            color: offre.daysLeft <= 5 ? AppColors.errorBg : AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              Icons.access_time_rounded,
              size: 11,
              color: offre.daysLeft <= 5 ? AppColors.error : AppColors.neutral600,
            ),
            const SizedBox(width: 4),
            Text(
              offre.daysLeft > 0
                  ? 'J-${offre.daysLeft} · ${DateFormat('dd MMM', 'fr').format(offre.deadline)}'
                  : 'Clôturé',
              style: AppTextStyles.labelXSmall.copyWith(
                color: offre.daysLeft <= 5 ? AppColors.error : AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
