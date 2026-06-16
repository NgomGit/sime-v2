// ─────────────────────────────────────────────────────────────────────────────
// Stepper bar
// ─────────────────────────────────────────────────────────────────────────────
// Couleurs :
//   • Cercle fait / courant → marron secondary800 (état institutionnel actif)
//   • Coche check         → vert primary400 (validation positive)
//   • Connecteur fait     → marron secondary400 (progression institutionnelle)
//   • Connecteur futur    → neutral100 (non atteint)
//   • Label courant       → secondary800 (ancre l'étape active)
import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class StepperBar extends StatelessWidget {
  const StepperBar({super.key, required this.currentStep, required this.steps});

  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, AppDimensions.sp14,
        AppDimensions.sp20, AppDimensions.sp16,
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          // Connecteur horizontal entre deux cercles
          if (i.isOdd) {
            final stepBefore = (i ~/ 2) + 1;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: stepBefore < currentStep
                      ? AppColors.secondary400  // marron : étape franchie
                      : AppColors.neutral100,   // gris : à venir
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          final step = i ~/ 2 + 1;
          final isDone = step < currentStep;
          final isCurrent = step == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: isCurrent ? 28 : 26,
                height: isCurrent ? 28 : 26,
                decoration: BoxDecoration(
                  // Fait ou courant → marron institutionnel
                  // Futur           → fond neutre très doux
                  color: isDone || isCurrent
                      ? AppColors.secondary800
                      : AppColors.neutral50,
                  border: Border.all(
                    color: isDone || isCurrent
                        ? AppColors.secondary800
                        : AppColors.neutral200,
                    width: isCurrent
                        ? AppDimensions.borderMedium
                        : AppDimensions.borderThin,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isDone
                    // Coche en vert ANPEJ sur fond marron — contraste net
                    ? const Icon(Icons.check, color: AppColors.surface, size: 14)
                    : Text(
                        '$step',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isCurrent
                              ? AppColors.white
                              : AppColors.neutral400,
                          fontSize: 11,
                        ),
                      ),
              ),
              const SizedBox(height: AppDimensions.sp4),
              Text(
                steps[i ~/ 2],
                style: AppTextStyles.labelXSmall.copyWith(
                  color: isCurrent
                      ? AppColors.secondary800  // marron : étape active
                      : isDone
                          ? AppColors.secondary400 // marron doux : étape passée
                          : AppColors.neutral300,  // gris : à venir
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

