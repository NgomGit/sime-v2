import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_dimensions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCard
// ─────────────────────────────────────────────────────────────────────────────
/// Card avec variante sombre (écran onboarding / héro dark).
///
/// • [isDark] = true  → fond [AppColors.darkSurfaceCard], bordure [AppColors.darkBorder]
///   splash/highlight indexés sur le vert ANPEJ (visible sur fond sombre)
/// • [isDark] = false → fond [AppColors.surface], bordure [AppColors.border]
///   splash/highlight indexés sur le marron institutionnel (visible sur fond blanc)
class SCard extends StatelessWidget {
  const SCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.radius,
    this.onTap,
    this.isDark = false,
  });
 
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double? radius;
  final VoidCallback? onTap;
  final bool isDark;
 
  @override
  Widget build(BuildContext context) {
    // Sur fond sombre : darkSurfaceCard (#1A2412) — légèrement plus clair que darkSurface
    // Sur fond clair  : surface (#FFFFFF)
    final effectiveColor = color ??
        (isDark ? AppColors.darkSurfaceCard : AppColors.surface);
 
    final effectiveBorder = borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.border);
 
    final effectiveRadius = radius ?? AppDimensions.radiusLG;
 
    // Ripple : marron sur fond clair, vert sur fond sombre (tous deux visibles)
    final splashColor = isDark
        ? AppColors.primary400.withAlpha(25)
        : AppColors.secondary800.withAlpha(15);
    final highlightColor = isDark
        ? AppColors.primary400.withAlpha(12)
        : AppColors.secondary800.withAlpha(8);
 
    return Material(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveRadius),
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: Border.all(
              color: effectiveBorder,
              width: AppDimensions.borderThin,
            ),
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.sp16),
            child: child,
          ),
        ),
      ),
    );
  }
}