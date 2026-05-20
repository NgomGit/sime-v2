import 'package:flutter/material.dart';
import '../tokens/app_dimensions.dart';
import '../tokens/app_text_styles.dart';

/// Compact label for contract type, location, etc.
class STag extends StatelessWidget {
  const STag({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp8,
        vertical: AppDimensions.sp4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(label, style: AppTextStyles.labelXSmall.copyWith(color: textColor)),
    );
  }
}
