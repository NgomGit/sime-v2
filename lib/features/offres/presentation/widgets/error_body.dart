import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class ErrorBody extends StatelessWidget {
  const ErrorBody({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.sp32),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            // Indicateur visuel d'erreur doux
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20), // Fond rouge très atténué
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error, 
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.sp20),
            
            // Titre de l'état d'erreur
            Text(
              'Une erreur est survenue',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sp8),
            
            // Message technique ou de feedback
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sp24),
            
            // Bouton d'action "Réessayer" (Vert ANPEJ)
            SizedBox(
              height: AppDimensions.buttonHeightSM,
              child: Material(
                color: AppColors.primary400, // Alignement charte graphique ANPEJ
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.sp24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: AppDimensions.iconSM,
                          color: AppColors.white, // Blanc pour un contraste optimal sur le vert
                        ),
                        SizedBox(width: AppDimensions.sp8),
                        Text(
                          'Réessayer', 
                          style: AppTextStyles.buttonSmall, // Utilisation du style blanc de base ou forcé en blanc
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}