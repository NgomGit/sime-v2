import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_card.dart';

 
class InfoSectionCard extends StatelessWidget {
  const InfoSectionCard({
    super.key,
    required this.title,
    required this.rows,
    required this.onEditTap,
  });
 
  final String title;
  final List<(String key, String value)> rows;
  final VoidCallback onEditTap;
 
  @override
  Widget build(BuildContext context) {
    return SCard(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.neutral800,
                ),
              ),
              GestureDetector(
                onTap: onEditTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 11,
                      // primary600 : lien discret mais lisible sur blanc
                      color: AppColors.primary600,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Modifier',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp10),
 
          // Lignes clé / valeur
          ...rows.map((row) {
            final isLast = row == rows.last;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp6),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Clé — neutre moyen
                  Text(
                    row.$1,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sp12),
                  // Valeur — neutre sombre, alignée à droite
                  Expanded(
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neutral800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
 