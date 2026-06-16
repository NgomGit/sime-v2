// ─── Similar offres ───────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/core/design_system/widgets/s_tag.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';

class SimilarSection extends StatelessWidget {
  const SimilarSection({super.key, required this.offres, required this.onTap});
  final List<OffreEntity> offres;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Offres similaires', style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800)),
          Text('Voir tout',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary400, fontWeight: FontWeight.w600)),
        ],
      ),
      const SizedBox(height: AppDimensions.sp12),
      ...offres.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sp8),
            child: _SimilarCard(offre: o, onTap: () => onTap(o.id)),
          )),
    ]);
  }
}

class _SimilarCard extends StatelessWidget {
  const _SimilarCard({required this.offre, required this.onTap});
  final OffreEntity offre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.sp14),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.border)),
          alignment: Alignment.center,
          child: const Icon(Icons.work_outline,
              size: AppDimensions.iconSM, color: AppColors.neutral500),
        ),
        const SizedBox(width: AppDimensions.sp12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(offre.title,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${offre.company} · ${offre.location}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600)),
            const SizedBox(height: AppDimensions.sp6),
            Wrap(spacing: AppDimensions.sp4, children: [
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
            ]),
          ]),
        ),
        const Icon(Icons.chevron_right,
            size: AppDimensions.iconSM, color: AppColors.neutral300),
      ]),
    );
  }
}
