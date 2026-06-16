// ─────────────────────────────────────────────────────────────────────────────
// Footer actions
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';

class FooterActions extends StatelessWidget {
  const FooterActions({super.key, 
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
  });

  final int currentStep, totalSteps;
  final VoidCallback onNext, onBack;

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, AppDimensions.sp14,
        AppDimensions.sp20, AppDimensions.sp24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimensions.borderThin),
        ),
      ),
      child: Row(
        children: [
          if (currentStep > 1) ...[
            Expanded(
              child: SButton(
                label: 'Retour',
                onPressed: onBack,
                variant: SButtonVariant.outline,
              ),
            ),
            const SizedBox(width: AppDimensions.sp10),
          ],
          Expanded(
            flex: currentStep > 1 ? 2 : 1,
            child: SButton(
              // Dernière étape → primary (marron) — acte d'engagement fort
              // Étapes intermédiaires → primary (marron) — progression institutionnelle
              label: isLastStep ? "Terminer l'inscription" : 'Continuer',
              onPressed: onNext,
              variant: SButtonVariant.primary,
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}