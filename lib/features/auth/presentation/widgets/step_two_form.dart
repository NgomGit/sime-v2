// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Profil
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';

class StepTwoForm extends StatelessWidget {
  const StepTwoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil & compétences',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp4),
        Text(
          'Aidez votre conseiller à mieux vous orienter',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppDimensions.sp24),
        const Row(
          children: [
            Expanded(child: SDropdown(label: "Niveau d'étude *", value: 'Supérieur')),
            SizedBox(width: AppDimensions.sp12),
            Expanded(child: SDropdown(label: 'Expérience', value: 'Choisir')),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: 'Domaine de formation', value: 'Numérique & IT'),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: "Domaine d'activité", value: 'Informatique'),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: 'Dernier diplôme obtenu', value: 'Licence'),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: 'Situation matrimoniale', value: 'Célibataire'),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: 'Type handicap', value: 'Aucun'),
      ],
    );
  }
}