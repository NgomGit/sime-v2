import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_dimensions.dart';
import '../tokens/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SButton
// ─────────────────────────────────────────────────────────────────────────────
enum SButtonVariant { primary, secondary, outline, ghost }
enum SButtonSize { large, medium, small }
 
/// Bouton SIME conforme à la hiérarchie ANPEJ :
///
/// • [primary]   → Marron institutionnel [secondary800] sur fond blanc.
///   C'est l'action principale de l'institution (S'inscrire, Se connecter,
///   Enregistrer, Terminer). Le marron distingue l'institution du contenu.
///
/// • [secondary] → Vert ANPEJ [primary400]. Action positive non-destructive
///   (Postuler, Voir l'offre). Le vert signale une opportunité d'avenir.
///
/// • [outline]   → Bordure marron [secondary400], texte marron [secondary800].
///   Action alternative (Retour, J'ai déjà un compte).
///
/// • [ghost]     → Fond neutre chaud [neutral100], texte [neutral600].
///   Action tertiaire discrète.
class SButton extends StatelessWidget {
  const SButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SButtonVariant.primary,
    this.size = SButtonSize.large,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });
 
  final String label;
  final VoidCallback? onPressed;
  final SButtonVariant variant;
  final SButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
 
  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      SButtonSize.large  => AppDimensions.buttonHeight,
      SButtonSize.medium => AppDimensions.buttonHeightSM,
      SButtonSize.small  => 34.0,
    };
    final textStyle = switch (size) {
      SButtonSize.large  => AppTextStyles.buttonLarge,
      SButtonSize.medium => AppTextStyles.buttonMedium,
      SButtonSize.small  => AppTextStyles.buttonSmall,
    };
    final radius = switch (size) {
      SButtonSize.large  => AppDimensions.radiusLG,
      SButtonSize.medium => AppDimensions.radiusMD,
      SButtonSize.small  => AppDimensions.radiusSM,
    };
 
    final (bgColor, fgColor, borderColor) = switch (variant) {
      // Marron institutionnel — CTA principal
      SButtonVariant.primary => (
        AppColors.secondary800,
        AppColors.white,
        Colors.transparent,
      ),
      // Vert ANPEJ — action positive (Postuler, Confirmer)
      SButtonVariant.secondary => (
        AppColors.primary400,
        AppColors.white,
        Colors.transparent,
      ),
      // Outline marron — action alternative
      SButtonVariant.outline => (
        Colors.transparent,
        AppColors.secondary800,
        AppColors.secondary400,
      ),
      // Ghost neutre chaud — action tertiaire
      SButtonVariant.ghost => (
        AppColors.neutral100,
        AppColors.neutral600,
        Colors.transparent,
      ),
    };
 
    final effectiveFg = isDisabled ? AppColors.neutral400 : fgColor;
    final effectiveBg = isDisabled ? AppColors.neutral100 : bgColor;
    final effectiveBorder = isDisabled ? Colors.transparent : borderColor;
 
    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: effectiveFg,
            ),
          ),
        ] else ...[
          if (leadingIcon != null) ...[
            Icon(leadingIcon, color: effectiveFg, size: AppDimensions.iconSM),
            const SizedBox(width: AppDimensions.sp8),
          ],
          Text(label, style: textStyle.copyWith(color: effectiveFg)),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppDimensions.sp8),
            Icon(trailingIcon, color: effectiveFg, size: AppDimensions.iconSM),
          ],
        ],
      ],
    );
 
    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: (isDisabled || isLoading) ? null : onPressed,
          borderRadius: BorderRadius.circular(radius),
          splashColor: effectiveFg.withAlpha(20),
          highlightColor: effectiveFg.withAlpha(10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: effectiveBorder != Colors.transparent
                  ? Border.all(
                      color: effectiveBorder,
                      width: AppDimensions.borderUltraThin,
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size == SButtonSize.small
                    ? AppDimensions.sp12
                    : AppDimensions.sp20,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}