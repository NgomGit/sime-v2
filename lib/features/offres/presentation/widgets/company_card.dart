import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';

class CompanyCard extends StatelessWidget {
  const CompanyCard({super.key, required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    return SCard(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.border)),
            alignment: Alignment.center,
            child: const Icon(Icons.corporate_fare_outlined,
                size: AppDimensions.iconMD, color: AppColors.neutral500),
          ),
          const SizedBox(width: AppDimensions.sp12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offre.company, style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800)),
              if (offre.companySize != null)
                Text(offre.companySize!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
            ]),
          ),
        ]),
        if (offre.companyDescription != null) ...[
          const SizedBox(height: AppDimensions.sp12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.sp12),
          Text(offre.companyDescription!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600, height: 1.5)),
        ],
      ]),
    );
  }
}
