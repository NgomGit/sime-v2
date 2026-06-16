import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_theme.dart';
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
  void initState() {
    super.initState();
    // Fond sombre → icônes status bar claires
    AppTheme.applyDarkStatusBar();
  }

  @override
  void dispose() {
    AppTheme.applyLightStatusBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond vert forêt sombre — même héro que l'onboarding
      // Cohérence totale avec le screen 2/19 du PDF ANPEJ
      backgroundColor: AppColors.darkSurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header sombre ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.sp20, AppDimensions.sp24,
                  AppDimensions.sp20, AppDimensions.sp24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bouton retour — fond semi-transparent sur fond sombre
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.onboarding),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.darkBorder, // blanc 10% — visible sur fond forêt
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back,
                          size: AppDimensions.iconSM,
                          color: AppColors.darkTextPrimary, // blanc sur fond sombre
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp24),

                    // Titre blanc + accent vert ANPEJ
                    // Pattern identique à "Votre avenir commence ici"
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.darkTextPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Ravi de vous\nrevoir '),
                          TextSpan(
                            text: 'parmi nous',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.primary400, // vert ANPEJ — seul accent
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

            // ── Formulaire ────────────────────────────────────────────────────
            // Même pattern que l'onboarding : bottom sheet blanc sur fond teinté
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.sp24, AppDimensions.sp20,
                AppDimensions.sp24, AppDimensions.sp32,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral800.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXXL),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40, height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),

                  Text(
                    'Espace de connexion',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp16),

                  // Champ téléphone — focus ring marron (via SPhoneField mis à jour)
                  const SPhoneField(label: 'Numéro de téléphone *'),
                  const SizedBox(height: AppDimensions.sp14),

                  // Champ mot de passe
                  const SField(
                    label: 'Mot de passe *',
                    hint: '••••••••••••',
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: AppDimensions.sp12),

                  // ── Actions secondaires ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Checkbox "Se souvenir de moi"
                      // activeColor = marron institutionnel (état coché = engagement)
                      // cohérence avec CheckboxTheme défini dans AppTheme
                      GestureDetector(
                        onTap: () =>
                            setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24, height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.secondary800, // marron institutionnel
                                checkColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) => setState(
                                  () => _rememberMe = val ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp6),
                            Text(
                              'Se souvenir de moi',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Lien "Mot de passe oublié" — vert ANPEJ
                      // Les liens texte = primary600 (vert moyen, lisible sur blanc)
                      // Le marron est réservé aux éléments interactifs à fort poids visuel
                      GestureDetector(
                        onTap: () {
                          // TODO: routage mot de passe oublié
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sp24),

                  // CTA principal — marron institutionnel (SButtonVariant.primary)
                  SButton(
                    label: 'Se connecter',
                    onPressed: () => context.go(AppRoutes.dashboard),
                    variant: SButtonVariant.primary,
                    trailingIcon: Icons.login_rounded,
                  ),
                  const SizedBox(height: AppDimensions.sp16),

                  // Lien inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vous n'avez pas de compte ? ",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: Text(
                          'Inscrivez-vous',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary600, // vert moyen — lien discret mais lisible
                            fontWeight: FontWeight.w700,
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