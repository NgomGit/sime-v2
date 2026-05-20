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
      padding: const EdgeInsets.all(AppDimensions.sp14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.labelLarge),
              GestureDetector(
                onTap: onEditTap,
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 11, color: AppColors.primary400),
                    const SizedBox(width: 3),
                    Text(
                      'Modifier',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp10),
          // Dynamic Row Rendering
          ...rows.map((row) {
            final isLast = row == rows.last;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.$1,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.labelMedium.copyWith(
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