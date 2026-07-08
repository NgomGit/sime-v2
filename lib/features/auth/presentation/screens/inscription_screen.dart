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

  void _handleBackNavigation() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      final canPop = Navigator.of(context).canPop();
      if (canPop) {
        Navigator.of(context).pop();
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: AppDimensions.sp16),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: AppDimensions.iconSM),
              color: AppColors.neutral800,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                side: const BorderSide(color: AppColors.border),
                fixedSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
              onPressed: _handleBackNavigation,
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
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.border, 
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                      ? Column(
                          key: const ValueKey(1),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StepOneForm(
                              selectedGenre: _selectedGenre,
                              onGenreChanged: (g) =>
                                  setState(() => _selectedGenre = g),
                            ),
                            const SizedBox(height: AppDimensions.sp20),
                        
                          ],
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
    debugPrint('Results are : $result');
    if (result.sex != null) {
      setState(() {
        _selectedGenre = result.sex;
      });
    }
  }
}

// // ─────────────────────────────────────────────────────────────────────────────
// // Sub-Widget: Tuile de sélection du Genre
// // ─────────────────────────────────────────────────────────────────────────────
// class _GenreSelectorTile extends StatelessWidget {
//   const _GenreSelectorTile({
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         height: AppDimensions.inputHeight,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.secondary800 : AppColors.white,
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//           border: Border.all(
//             color: isSelected ? AppColors.secondary800 : AppColors.border,
//             width: isSelected ? AppDimensions.borderMedium : AppDimensions.borderThin,
//           ),
//         ),
//         child: Text(
//           label,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: isSelected ? AppColors.white : AppColors.neutral600,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//           ),
//         ),
//       ),
//     );
//   }
// }