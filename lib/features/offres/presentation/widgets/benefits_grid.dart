// ─── Benefits grid ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class BenefitsGrid extends StatelessWidget {
  const BenefitsGrid({super.key, required this.items});
  final List<String> items;

  static const _icons = [
    Icons.payments_outlined,
    Icons.health_and_safety_outlined,
    Icons.laptop_outlined,
    Icons.home_work_outlined,
    Icons.school_outlined,
    Icons.emoji_events_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.sp8,
        crossAxisSpacing: AppDimensions.sp8,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (_, i) {
        final icon = _icons[i % _icons.length];
        return Container(
          padding: const EdgeInsets.all(AppDimensions.sp10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: AppColors.secondary100, // Marron doux pour l'univers corporatif/avantages
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: AppDimensions.iconXS, color: AppColors.secondary800),
            ),
            const SizedBox(width: AppDimensions.sp8),
            Expanded(
              child: Text(items[i],
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.neutral800, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        );
      },
    );
  }
}
