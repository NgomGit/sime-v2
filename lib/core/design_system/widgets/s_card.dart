import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_dimensions.dart';

/// SIME Design System — Elevated card with optional dark variant.
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
    final effectiveColor = color ??
        (isDark ? AppColors.darkSurface : AppColors.surface);
    final effectiveBorder = borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.border);
    final effectiveRadius = radius ?? AppDimensions.radiusLG;

    return Material(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveRadius),
        splashColor: AppColors.primary400.withAlpha(20),
        highlightColor: AppColors.primary400.withAlpha(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: Border.all(color: effectiveBorder, width: AppDimensions.borderThin),
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
