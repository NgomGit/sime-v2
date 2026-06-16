import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/providers/scan_result_provider.dart';
import 'package:sime_v2/core/services/scanned_document.dart';
import 'package:sime_v2/features/auth/presentation/widgets/footer_actions.dart';
import 'package:sime_v2/features/auth/presentation/widgets/step_one_form.dart';
import 'package:sime_v2/features/auth/presentation/widgets/step_three_form.dart';
import 'package:sime_v2/features/auth/presentation/widgets/step_two_form.dart';
import 'package:sime_v2/features/auth/presentation/widgets/stepper_bar.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final result = ref.read(scanResultProvider);
      if (result != null) _fillFields(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppDimensions.sp16),
          child: GestureDetector(
            onTap: () => _currentStep > 1
                ? setState(() => _currentStep--)
                : Navigator.of(context).canPop()
                    ? Navigator.of(context).pop()
                    : context.go(AppRoutes.onboarding),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                size: AppDimensions.iconSM,
                color: AppColors.neutral800,
              ),
            ),
          ),
        ),
        title: Text(
          'Inscription',
          style: AppTextStyles.headingSmall.copyWith(
            color: AppColors.neutral800,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppDimensions.sp16),
              child: Text(
                'Étape $_currentStep / ${_steps.length}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ),
          ),
        ],
        // Bordure bottom conforme à AppBarTheme
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: AppDimensions.borderThin),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper sur fond surface blanc (dans la continuité de l'AppBar)
            ColoredBox(
              color: AppColors.surface,
              child: StepperBar(currentStep: _currentStep, steps: _steps),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _currentStep == 1
                      ? StepOneForm(
                          key: const ValueKey(1),
                          selectedGenre: _selectedGenre,
                          onGenreChanged: (g) =>
                              setState(() => _selectedGenre = g),
                        )
                      : _currentStep == 2
                          ? const StepTwoForm(key: ValueKey(2))
                          : const StepThreeForm(key: ValueKey(3)),
                ),
              ),
            ),
            FooterActions(
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

  void _fillFields(ScannedDocument result) {
    print('Results are : $result');
  }
}

