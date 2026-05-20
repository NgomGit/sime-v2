import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_button.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary900,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.sp20, AppDimensions.sp24,
                  AppDimensions.sp20, 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Badge ──────────────────────────────────────────────────
                    _AnpejBadge(),
                    const SizedBox(height: AppDimensions.sp20),

                    // ── Hero title ────────────────────────────────────────────
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.displayLarge,
                        children: [
                          const TextSpan(text: 'Votre avenir\ncommence '),
                          TextSpan(
                            text: 'ici',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.primary400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp12),
                    Text(
                      'Emploi, formation, financement et mobilité internationale — un seul espace pour accompagner chaque jeune sénégalais.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp24),

                    // ── Stats panel ───────────────────────────────────────────
                    _StatsPanel(),
                  ],
                ),
              ),
            ),

            // ── Bottom sheet CTA ──────────────────────────────────────────────
            _BottomCta(),
          ],
        ),
      ),
    );
  }
}

class _AnpejBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp14, vertical: AppDimensions.sp6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary400.withAlpha(30),
        border: Border.all(color: AppColors.primary400.withAlpha(60)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary400, shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text('ANPEJ · SIME V2', style: AppTextStyles.eyebrow),
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '48k+', label: 'Jeunes inscrits',
                  progress: 0.72, color: AppColors.primary400,
                  delta: '↑ +12% ce mois',
                ),
              ),
              SizedBox(width: AppDimensions.sp10),
              Expanded(
                child: _StatCard(
                  value: '3 200', label: 'Offres actives',
                  progress: 0.55, color: AppColors.accent500,
                  delta: '↑ +8% ce mois',
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.sp12),
          Wrap(
            spacing: AppDimensions.sp6,
            runSpacing: AppDimensions.sp6,
            children: [
              _ServicePill(label: 'Emploi salarié', isActive: true),
              _ServicePill(label: 'Formation'),
              _ServicePill(label: 'Auto-emploi'),
              _ServicePill(label: 'Migration int.', isActive: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
    required this.delta,
  });
  final String value, label, delta;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sp12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.darkTextHint)),
          const SizedBox(height: AppDimensions.sp8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress, minHeight: 3,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppDimensions.sp4),
          Text(delta, style: AppTextStyles.labelXSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ServicePill extends StatelessWidget {
  const _ServicePill({required this.label, this.isActive = false});
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp10, vertical: AppDimensions.sp6,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary400.withAlpha(38) : Colors.white.withAlpha(15),
        border: Border.all(
          color: isActive ? AppColors.primary400.withAlpha(76) : Colors.white.withAlpha(20),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isActive ? AppColors.primary400 : AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp24, AppDimensions.sp24,
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
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sp20),
          const Text('Commencer maintenant', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppDimensions.sp4),
          const Text('Créez votre dossier gratuitement en 3 étapes', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppDimensions.sp20),
          SButton(
            label: 'Créer mon compte',
            onPressed: () {
              context.push(AppRoutes.register);
            },
            trailingIcon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: AppDimensions.sp10),
          SButton(
            label: "J'ai déjà un compte",
            onPressed: () {
              context.push(AppRoutes.login);
            },
            variant: SButtonVariant.outline,
          ),
        ],
      ),
    );
  }
}
