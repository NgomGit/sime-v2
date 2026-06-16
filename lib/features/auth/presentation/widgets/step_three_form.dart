import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Besoin sollicité
// ─────────────────────────────────────────────────────────────────────────────
// Chaque service a sa couleur sémantique ANPEJ :
//   Emploi salarié       → vert   primary
//   Financement          → jaune  accent
//   Formation            → bleu   bleuANPEJ
//   Mobilité int.        → violet violetANPEJ
//
// Sélectionné : bordure + fond teinté + icône colorée + radio marron
// Non sélectionné : fond neutral50, icône grise, radio vide
class StepThreeForm extends StatefulWidget {
  const StepThreeForm({super.key});

  @override
  State<StepThreeForm> createState() => _StepThreeFormState();
}

class _StepThreeFormState extends State<StepThreeForm> {
  int _selected = 0;

  // Couleur sémantique par service — conforme à la charte ANPEJ
  static const _services = [
    (
      icon: Icons.work_outline,
      label: 'Emploi salarié',
      desc: 'Emploi, stage, coaching',
      color: AppColors.primary400,       // vert ANPEJ
      bgColor: AppColors.primary100,
    ),
    (
      icon: Icons.rocket_launch_outlined,
      label: 'Financement',
      desc: "Plan d'affaire, incubation",
      color: AppColors.accent500,        // jaune ANPEJ
      bgColor: AppColors.accent100,
    ),
    (
      icon: Icons.school_outlined,
      label: 'Formation',
      desc: '3FPT, FORCEN, UVS...',
      color: AppColors.bleuANPEJ,        // bleu ANPEJ
      bgColor: AppColors.bleuANPEJBg,
    ),
    (
      icon: Icons.flight_outlined,
      label: 'Mobilité internationale',
      desc: 'CSAEM, migration pro.',
      color: AppColors.violetANPEJ,      // violet ANPEJ
      bgColor: AppColors.violetANPEJBg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Besoin sollicité',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp4),
        Text(
          'Choisissez votre service principal',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppDimensions.sp24),
        ..._services.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final isSel = _selected == i;

          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: AppDimensions.sp10),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sp14,
                vertical: AppDimensions.sp12,
              ),
              decoration: BoxDecoration(
                // Sélectionné : fond teinté de la couleur du service
                // Non sélectionné : fond neutre blanc
                color: isSel ? s.bgColor : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  // Bordure couleur service si sélectionné, sinon neutre
                  color: isSel ? s.color : AppColors.border,
                  width: isSel
                      ? AppDimensions.borderMedium
                      : AppDimensions.borderThin,
                ),
              ),
              child: Row(
                children: [
                  // Icône du service — couleur sémantique si sélectionné
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: isSel ? s.bgColor : AppColors.neutral50,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      border: Border.all(
                        color: isSel
                            ? s.color.withAlpha(60)
                            : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      s.icon,
                      size: AppDimensions.iconMD,
                      color: isSel ? s.color : AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sp12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.label,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isSel ? AppColors.neutral800 : AppColors.neutral600,
                          ),
                        ),
                        Text(
                          s.desc,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Radio button — marron institutionnel quand coché
                  // (le choix d'un service = engagement envers l'institution)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel
                          ? AppColors.secondary800
                          : Colors.transparent,
                      border: Border.all(
                        color: isSel
                            ? AppColors.secondary800
                            : AppColors.neutral200,
                        width: AppDimensions.borderMedium,
                      ),
                    ),
                    child: isSel
                        ? const Icon(
                            Icons.check,
                            size: 10,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

