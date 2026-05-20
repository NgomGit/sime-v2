import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

enum SimeButtonVariant { primary, outline, ghost, danger }
enum ButtonSize { large, small }

class SimeButton extends StatelessWidget {
  const SimeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SimeButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = true,
    this.size = ButtonSize.large,
  });

  final String label;
  final VoidCallback? onPressed;
  final SimeButtonVariant variant;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final double height = size == ButtonSize.large
        ? AppDimensions.buttonHeight
        : AppDimensions.buttonHeightSm;
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case SimeButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary900,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
          ),
          child: _content(AppColors.primary500, AppColors.white),
        );
      case SimeButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neutral900,
            side: const BorderSide(color: AppColors.neutral200, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
          ),
          child: _content(AppColors.neutral600, AppColors.neutral900),
        );
      case SimeButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary800,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
          ),
          child: _content(AppColors.primary500, AppColors.primary800),
        );
      case SimeButtonVariant.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
          ),
          child: _content(AppColors.white, AppColors.white),
        );
    }
  }

  Widget _content(Color iconColor, Color textColor) {
    if (isLoading) {
      return SizedBox(width: 20, height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(data: IconThemeData(color: iconColor, size: 18), child: icon!),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTextStyles.button.copyWith(color: textColor)),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          IconTheme(data: IconThemeData(color: iconColor, size: 18), child: trailingIcon!),
        ],
      ],
    );
  }
}
