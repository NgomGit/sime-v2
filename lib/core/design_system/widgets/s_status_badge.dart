import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_text_styles.dart';
import '../tokens/app_dimensions.dart';

enum SStatusVariant { success, warning, error, info, neutral }

/// Pill-shaped status badge used throughout the app.
class SStatusBadge extends StatelessWidget {
  const SStatusBadge({
    super.key,
    required this.label,
    this.variant = SStatusVariant.success,
    this.showDot = true,
  });

  final String label;
  final SStatusVariant variant;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      SStatusVariant.success => (AppColors.successBg, AppColors.primary800),
      SStatusVariant.warning => (AppColors.warningBg, const Color(0xFF795B00)),
      SStatusVariant.error   => (AppColors.errorBg,   AppColors.error),
      SStatusVariant.info    => (AppColors.infoBg,    AppColors.info),
      SStatusVariant.neutral => (AppColors.neutral100, AppColors.neutral500),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp10,
        vertical: AppDimensions.sp4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 5, height: 5,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTextStyles.labelXSmall.copyWith(color: fg)),
        ],
      ),
    );
  }
}
