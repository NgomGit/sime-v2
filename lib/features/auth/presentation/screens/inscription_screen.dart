// features/auth/presentation/screens/inscription_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/widgets/app_status_dialog.dart';
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart'; // Import de notre loader global
import 'package:sime_v2/features/auth/presentation/widgets/footer_actions.dart';
import 'package:sime_v2/features/auth/presentation/widgets/step_one_form.dart';
import 'package:sime_v2/features/auth/presentation/widgets/step_three_form.dart'; 
import 'package:sime_v2/features/auth/presentation/widgets/step_two_form.dart';
import 'package:sime_v2/features/auth/presentation/widgets/stepper_bar.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../providers/registration_provider.dart';

class InscriptionScreen extends ConsumerWidget {
  const InscriptionScreen({super.key});

  // Définition propre des 3 étapes distinctes
  static const _steps = ['Informations', 'Documents', 'Compte'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationState = ref.watch(registrationNotifierProvider);
    final notifier = ref.read(registrationNotifierProvider.notifier);

    ref.listen(registrationNotifierProvider, (previous, next) {
      if (next.isSuccess) {
        AppStatusDialog.show(
          context,
          title: 'Félicitations !',
          message: 'Votre compte et votre dossier demandeur ont été configurés avec succès.',
          type: StatusDialogType.success,
          onConfirm: () {
            notifier.resetSteps(); // Réinitialisation de l'état pour une nouvelle inscription
            context.go(AppRoutes.login);
          },
        );
      }

      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        AppStatusDialog.show(
          context,
          title: 'Création impossible',
          message: next.errorMessage!,
          type: StatusDialogType.error,
        );
      }
    });

    // Enveloppement global avec SOverlayLoader connecté au state de l'API
    return SOverlayLoader(
      isLoading: registrationState.isLoading,
      child: Scaffold(
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
                onPressed: () {
                  if (registrationState.currentStep > 1) {
                    notifier.prevStep();
                  } else {
                    context.go(AppRoutes.onboarding);
                  }
                },
              ),
            ),
          ),
          title: Text(
            'Inscription',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimensions.sp16),
                child: Text(
                  'Étape ${registrationState.currentStep} / ${_steps.length}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
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
                child: StepperBar(
                  currentStep: registrationState.currentStep,
                  steps: _steps,
                ),
              ),
              // Remplacement de l'ancien LinearProgressIndicator par le loader global transparent
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildFormForStep(registrationState.currentStep),
                  ),
                ),
              ),
              FooterActions(
                currentStep: registrationState.currentStep,
                totalSteps: _steps.length,
                onNext: () {
                  if (registrationState.currentStep < _steps.length) {
                    notifier.nextStep();
                  } else {
                    notifier.submit();
                  }
                },
                onBack: () {
                  if (registrationState.currentStep > 1) notifier.prevStep();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper pour commuter proprement les formulaires avec des ValueKeys uniques
  Widget _buildFormForStep(int step) {
    switch (step) {
      case 1:
        return const StepOneForm(key: ValueKey(1));
      case 2:
        return const StepTwoForm(key: ValueKey(2));
      case 3:
      default:
        return const StepThreeForm(key: ValueKey(3));
    }
  }
}