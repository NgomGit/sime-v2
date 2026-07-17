import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

enum GenreTileGender { male, female }

/// Carte de sélection du genre — icône (homme/femme) + libellé, cochée d'un
/// badge check quand sélectionnée.
///
/// Couleur de sélection unifiée sur [AppColors.secondary800] (marron
/// institutionnel) pour les deux genres plutôt qu'un code couleur par genre :
/// cohérent avec le reste du langage de sélection de l'app (jour sélectionné
/// dans l'agenda, cartes confirmées, CTA...), et évite d'attribuer un sens
/// arbitraire à une couleur pour une donnée démographique.
class GenreTile extends StatelessWidget {
  const GenreTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.gender,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final GenreTileGender gender;

  IconData get _icon =>
      gender == GenreTileGender.male ? Icons.male_rounded : Icons.female_rounded;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      splashColor: AppColors.secondary800.withAlpha(15),
      highlightColor: AppColors.secondary800.withAlpha(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.sp16,
          horizontal: AppDimensions.sp12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary50 : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isSelected ? AppColors.secondary800 : AppColors.border,
            width: isSelected ? AppDimensions.borderMedium : AppDimensions.borderThin,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary800 : AppColors.neutral50,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _icon,
                    size: AppDimensions.iconLG,
                    color: isSelected ? AppColors.white : AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: AppDimensions.sp8),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.secondary800 : AppColors.neutral600,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Badge de sélection — apparaît avec un léger effet de rebond
            Positioned(
              top: -4,
              right: 4,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1 : 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.secondary800,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check_rounded, size: 12, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
