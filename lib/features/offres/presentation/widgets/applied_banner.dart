// Complétion des widgets internes manquants suite à la coupure
import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class AppliedBanner extends StatelessWidget {
  const AppliedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(20),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.success.withAlpha(40)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: AppDimensions.sp8),
          Text(
            'Vous avez déjà postulé',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}