import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_button.dart';

class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key});

  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary900,
      body: SafeArea(
        child: Column(
          children: [
            // ── Upper Deep Dark Core ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.sp20, AppDimensions.sp24,
                  AppDimensions.sp20, AppDimensions.sp24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Navigation Button
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.onboarding),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back, 
                          size: AppDimensions.iconSM, 
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp24),

                    // Title Header
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.displayLarge,
                        children: [
                          const TextSpan(text: 'Ravi de vous\nrevoir '),
                          TextSpan(
                            text: 'parmi nous',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.primary400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp12),
                    Text(
                      'Connectez-vous à votre espace ANPEJ pour suivre vos opportunités et mettre à jour votre dossier.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Sheet White Card Form ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.sp24, AppDimensions.sp28,
                AppDimensions.sp24, AppDimensions.sp32,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXXL),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull indicator element
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),

                  const Text('Espace de connexion', style: AppTextStyles.headingSmall),
                  const SizedBox(height: AppDimensions.sp14),

                  // Phone/Identifier Input Field
                  const SPhoneField(
                    label: 'Numéro de téléphone *',
                  ),
                  const SizedBox(height: AppDimensions.sp14),

                  // Password Input Field
                  const SField(
                    label: 'Mot de passe *',
                    hint: '••••••••••••',
                    keyboardType: TextInputType.visiblePassword,
                    
                    // Note: If SField doesn't expose suffixIcon natively, wrap 
                    // or adapt it inside your design system parameters.
                  ),
                  const SizedBox(height: AppDimensions.sp10),

                  // Remember Me & Forgot Password Layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24, height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary900,
                                checkColor: AppColors.primary400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp6),
                            Text(
                              'Se souvenir de moi',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.neutral800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle password recovery routing
                          // context.push(AppRoutes.forgotPassword);
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sp24),

                  // Form Primary Action Call to Action
                  SButton(
                    label: 'Se connecter',
                    onPressed: () {
                      // Perform authentication handling layer logic here
                      context.go(AppRoutes.dashboard);
                    },
                    trailingIcon: Icons.login_rounded,
                  ),
                  const SizedBox(height: AppDimensions.sp14),

                  // Secondary Action Redirecting to Registration Process
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vous n'avez pas de compte ? ",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.register);
                        },
                        child: Text(
                          "Inscrivez-vous",
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}