import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_dimensions.dart';
import '../tokens/app_text_styles.dart';

enum SButtonVariant { primary, secondary, outline, ghost }
enum SButtonSize { large, medium, small }

/// SIME Design System — Primary button component.
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
      SButtonVariant.primary => (
        AppColors.primary900, AppColors.white, Colors.transparent,
      ),
      SButtonVariant.secondary => (
        AppColors.primary400, AppColors.white, Colors.transparent,
      ),
      SButtonVariant.outline => (
        Colors.transparent, AppColors.primary900, AppColors.border,
      ),
      SButtonVariant.ghost => (
        const Color(0x0FFFFFFF), AppColors.darkTextSecondary, const Color(0x1FFFFFFF),
      ),
    };

    final effectiveFg = isDisabled ? AppColors.neutral300 : fgColor;
    final effectiveBg = isDisabled ? AppColors.neutral100 : bgColor;

    Widget content = Row(
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
            Icon(trailingIcon, color: AppColors.primary400, size: AppDimensions.iconSM),
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: borderColor, width: AppDimensions.borderMedium),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size == SButtonSize.small ? 12 : 20),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
