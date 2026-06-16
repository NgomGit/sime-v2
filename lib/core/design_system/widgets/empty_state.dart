import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.neutral200),
          SizedBox(height: AppDimensions.sp12),
          Text('Aucune offre trouvée', style: AppTextStyles.labelLarge),
          Text('Modifiez vos filtres', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
