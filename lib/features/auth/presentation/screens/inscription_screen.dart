import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_button.dart';

class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key});

  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends ConsumerState<InscriptionScreen> {
  int _currentStep = 1;
  String? _selectedGenre;

  static const _steps = ['Infos', 'Profil', 'Service'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppDimensions.sp16),
          child: GestureDetector(
            onTap: () => _currentStep > 1
                ? setState(() => _currentStep--)
                : Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back,
                  size: AppDimensions.iconSM, color: AppColors.neutral800),
            ),
          ),
        ),
        title: const Text('Inscription', style: AppTextStyles.headingSmall),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppDimensions.sp16),
              child: Text(
                'Étape $_currentStep / ${_steps.length}',
                style: AppTextStyles.caption,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepperBar(currentStep: _currentStep, steps: _steps),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _currentStep == 1
                      ? _StepOneForm(
                          key: const ValueKey(1),
                          selectedGenre: _selectedGenre,
                          onGenreChanged: (g) =>
                              setState(() => _selectedGenre = g),
                        )
                      : _currentStep == 2
                          ? const _StepTwoForm(key: ValueKey(2))
                          : const _StepThreeForm(key: ValueKey(3)),
                ),
              ),
            ),
            _FooterActions(
              currentStep: _currentStep,
              totalSteps: _steps.length,
              onNext: () {
                if (_currentStep < _steps.length) {
                  setState(() => _currentStep++);
                } else {
                  context.go(AppRoutes.login);
                }
              },
              onBack: () {
                if (_currentStep > 1) setState(() => _currentStep--);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stepper bar ──────────────────────────────────────────────────────────────
class _StepperBar extends StatelessWidget {
  const _StepperBar({required this.currentStep, required this.steps});
  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20,
        AppDimensions.sp14,
        AppDimensions.sp20,
        AppDimensions.sp4,
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepBefore = (i ~/ 2) + 1;
            return Expanded(
              child: Container(
                height: 2,
                color: stepBefore < currentStep
                    ? AppColors.primary900
                    : AppColors.neutral100,
              ),
            );
          }
          final step = i ~/ 2 + 1;
          final isDone = step < currentStep;
          final isCurrent = step == currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isCurrent ? 28 : 26,
                height: isCurrent ? 28 : 26,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.primary900
                      : isCurrent
                          ? AppColors.primary900
                          : AppColors.neutral50,
                  border: Border.all(
                    color: isDone || isCurrent
                        ? AppColors.primary900
                        : AppColors.neutral200,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check,
                        color: AppColors.primary400, size: 14)
                    : Text(
                        '$step',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isCurrent
                              ? AppColors.white
                              : AppColors.neutral400,
                        ),
                      ),
              ),
              const SizedBox(height: AppDimensions.sp4),
              Text(
                steps[i ~/ 2],
                style: AppTextStyles.labelXSmall.copyWith(
                  color:
                      isCurrent ? AppColors.primary900 : AppColors.neutral300,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Step 1 ───────────────────────────────────────────────────────────────────
class _StepOneForm extends StatelessWidget {
  const _StepOneForm({super.key, this.selectedGenre, this.onGenreChanged});
  final String? selectedGenre;
  final ValueChanged<String>? onGenreChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations personnelles',
            style: AppTextStyles.headingSmall),
        const SizedBox(height: AppDimensions.sp4),
        const Text('Tous les champs * sont obligatoires',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: AppDimensions.sp24),
        const Row(children: [
          Expanded(child: SField(label: 'Prénom *', hint: 'Mamadou')),
          SizedBox(width: AppDimensions.sp12),
          Expanded(child: SField(label: 'Nom *', hint: 'Aidara')),
        ]),
        const SizedBox(height: AppDimensions.sp14),
        Text('Genre *',
            style:
                AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        Row(
            children: ['Homme', 'Femme'].map((g) {
          final sel = selectedGenre == g;
          return Expanded(
            child: GestureDetector(
              onTap: () => onGenreChanged?.call(g),
              child: Container(
                margin: EdgeInsets.only(right: g == 'Homme' ? 8 : 0),
                height: 46,
                decoration: BoxDecoration(
                  color: sel ? AppColors.white : AppColors.neutral50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: sel ? AppColors.primary900 : AppColors.border,
                    width: sel
                        ? AppDimensions.borderMedium
                        : AppDimensions.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  g,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: sel ? AppColors.primary900 : AppColors.neutral400,
                  ),
                ),
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: AppDimensions.sp14),
        const Row(children: [
          Expanded(
              child: SField(
                  label: 'Date de naissance *',
                  hint: '15/03/2000',
                  isValid: true)),
          SizedBox(width: AppDimensions.sp12),
          Expanded(child: SField(label: 'Lieu de naissance *', hint: 'Dakar')),
        ]),
        const SizedBox(height: AppDimensions.sp14),
        const SPhoneField(
          label: 'Numéro de téléphone *',
        ),
        const SizedBox(height: AppDimensions.sp14),
        const SField(
            label: 'Numéro CIN',
            hint: '1234567890123',
            hint2: '13 caractères sans espaces'),
        const SizedBox(height: AppDimensions.sp14),
        const Row(children: [
          Expanded(child: SDropdown(label: 'Région *', value: 'Dakar')),
          SizedBox(width: AppDimensions.sp12),
          Expanded(child: SDropdown(label: 'Département *', value: 'Dakar')),
        ]),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: 'Nationalité', value: '🇸🇳 Sénégalaise'),
      ],
    );
  }
}

// ─── Step 2 ───────────────────────────────────────────────────────────────────
class _StepTwoForm extends StatelessWidget {
  const _StepTwoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profil & compétences', style: AppTextStyles.headingSmall),
        SizedBox(height: AppDimensions.sp4),
        Text('Aidez votre conseiller à mieux vous orienter',
            style: AppTextStyles.bodySmall),
        SizedBox(height: AppDimensions.sp24),
        Row(children: [
          Expanded(
              child: SDropdown(label: "Niveau d'étude *", value: 'Supérieur')),
          SizedBox(width: AppDimensions.sp12),
          Expanded(child: SDropdown(label: 'Expérience', value: 'Choisir')),
        ]),
        SizedBox(height: AppDimensions.sp14),
        SDropdown(label: 'Domaine de formation', value: 'Numérique & IT'),
        SizedBox(height: AppDimensions.sp14),
        SDropdown(label: "Domaine d'activité", value: "Informatique"),
        SizedBox(height: AppDimensions.sp14),
        SDropdown(label: 'Dernier diplôme obtenu', value: 'Licence'),
        SizedBox(height: AppDimensions.sp14),
        SDropdown(label: 'Situation matrimoniale', value: 'Célibataire'),
        SizedBox(height: AppDimensions.sp14),
        SDropdown(label: 'Type handicap', value: 'Aucun'),
      ],
    );
  }
}

// ─── Step 3 ───────────────────────────────────────────────────────────────────
class _StepThreeForm extends StatefulWidget {
  const _StepThreeForm({super.key});

  @override
  State<_StepThreeForm> createState() => _StepThreeFormState();
}

class _StepThreeFormState extends State<_StepThreeForm> {
  int _selected = 0;

  static const _services = [
    (
      icon: Icons.work_outline,
      label: 'Emploi salarié',
      desc: 'Emploi, stage, coaching'
    ),
    (
      icon: Icons.rocket_launch_outlined,
      label: 'Financement',
      desc: "Plan d'affaire, incubation"
    ),
    (
      icon: Icons.school_outlined,
      label: 'Formation',
      desc: '3FPT, FORCEN, UVS...'
    ),
    (
      icon: Icons.flight_outlined,
      label: 'Mobilité internationale',
      desc: 'CSAEM, migration pro.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Besoin sollicité', style: AppTextStyles.headingSmall),
        const SizedBox(height: AppDimensions.sp4),
        const Text('Choisissez votre service principal',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: AppDimensions.sp24),
        ..._services.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final isSel = _selected == i;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: AppDimensions.sp8),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sp14,
                vertical: AppDimensions.sp12,
              ),
              decoration: BoxDecoration(
                color: isSel ? AppColors.white : AppColors.neutral50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: isSel ? AppColors.primary900 : AppColors.border,
                  width: isSel
                      ? AppDimensions.borderMedium
                      : AppDimensions.borderThin,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary100 : AppColors.border,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      s.icon,
                      size: AppDimensions.iconMD,
                      color:
                          isSel ? AppColors.primary800 : AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sp12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.label, style: AppTextStyles.labelLarge),
                        Text(s.desc, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel ? AppColors.primary900 : Colors.transparent,
                      border: Border.all(
                        color:
                            isSel ? AppColors.primary900 : AppColors.neutral200,
                        width: AppDimensions.borderMedium,
                      ),
                    ),
                    child: isSel
                        ? const Icon(Icons.check,
                            size: 10, color: AppColors.primary400)
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

// ─── Footer actions ───────────────────────────────────────────────────────────
class _FooterActions extends StatelessWidget {
  const _FooterActions({
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
  });
  final int currentStep, totalSteps;
  final VoidCallback onNext, onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20,
        AppDimensions.sp14,
        AppDimensions.sp20,
        AppDimensions.sp24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (currentStep > 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimensions.sp10),
                child: SButton(
                  label: 'Retour',
                  onPressed: onBack,
                  variant: SButtonVariant.outline,
                ),
              ),
            ),
          Expanded(
            flex: currentStep > 1 ? 2 : 1,
            child: SButton(
              label: currentStep == totalSteps
                  ? 'Terminer l\'inscription'
                  : 'Continuer',
              onPressed: onNext,
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
