import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';

class RecruitmentStepper extends StatelessWidget {
  const RecruitmentStepper({super.key, required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return SCard(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final isLast = e.key == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Column(children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        color: AppColors.secondary600, shape: BoxShape.circle), // Remplacement de primary900 par le Marron
                    alignment: Alignment.center,
                    child: Text(
                      '${e.key + 1}',
                      style: AppTextStyles.labelXSmall
                          .copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isLast)
                    Container(
                        width: 1.5,
                        height: 28,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: AppColors.border),
                ]),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.sp10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(e.value, style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}


