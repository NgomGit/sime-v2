// features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_theme.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/design_system/widgets/app_status_dialog.dart';
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart';
import 'package:sime_v2/core/providers/secure_storage_provider.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    AppTheme.applyDarkStatusBar();
    // Chargement propre des préférences au démarrage de l'écran
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final isRememberMe = await secureStorage.readRememberMe();
    final savedUsername = await secureStorage.readSavedUsername();

    if (mounted) {
      setState(() {
        _rememberMe = isRememberMe;
        if (savedUsername != null && savedUsername.isNotEmpty) {
          _usernameController.text = savedUsername;
        }
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    AppTheme.applyLightStatusBar();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(loginNotifierProvider.notifier).login(
          username: username,
          password: password,
          rememberMe: _rememberMe,
        );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      final loginState = ref.read(loginNotifierProvider).valueOrNull;
      if (loginState?.errorMessage != null) {
        showDialog(
          context: context,
          builder: (context) => AppStatusDialog(
            title: 'Échec de connexion',
            message: loginState!.errorMessage!,
            type: StatusDialogType.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final isLoading = loginState.valueOrNull?.isLoading ?? false;

    return SOverlayLoader(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.darkSurface,
        body: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── Header sombre ─────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.sp20,
                      AppDimensions.sp24,
                      AppDimensions.sp20,
                      AppDimensions.sp24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.onboarding),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.darkBorder,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.arrow_back,
                              size: AppDimensions.iconSM,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sp24),
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

                // ── Formulaire (Bottom Sheet Blanc) ────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.sp24,
                    AppDimensions.sp20,
                    AppDimensions.sp24,
                    AppDimensions.sp32,
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
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
                        SField(
                          label: 'Nom d\'utilisateur *',
                          hint: 'Ex: user.name',
                          controller: _usernameController,
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.username],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez saisir votre nom d\'utilisateur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.sp14),
                        SPasswordField(
                          label: 'Mot de passe *',
                          hint: '••••••••••••',
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre mot de passe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.sp12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.secondary800,
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
                            GestureDetector(
                              onTap: () {
                                // TODO: context.push(AppRoutes.forgotPassword);
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
                        SButton(
                          label: 'Se connecter',
                          onPressed: isLoading ? null : _handleLogin,
                          variant: SButtonVariant.primary,
                          isLoading: isLoading,
                          trailingIcon: isLoading ? null : Icons.login_rounded,
                        ),
                        const SizedBox(height: AppDimensions.sp16),
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
                                  color: AppColors.primary600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}