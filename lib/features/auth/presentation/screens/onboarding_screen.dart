import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_theme.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Icônes de statut claires sur fond sombre (hero dark charte ANPEJ)
    AppTheme.applyDarkStatusBar();
  }

  @override
  void dispose() {
    // Restaure les icônes sombres pour les écrans suivants (fond blanc)
    AppTheme.applyLightStatusBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond vert forêt sombre — couleur héro de la charte ANPEJ
      backgroundColor: AppColors.darkSurface,
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
                    // ── Badge ANPEJ ───────────────────────────────────────────
                    const _AnpejBadge(),
                    const SizedBox(height: AppDimensions.sp24),

                    // ── Hero title ────────────────────────────────────────────
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.darkTextPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Votre avenir\ncommence '),
                          TextSpan(
                            text: 'ici',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.primary400, // Vert ANPEJ — seul accent lumineux
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
                    const SizedBox(height: AppDimensions.sp28),

                    // ── Stats panel ───────────────────────────────────────────
                    const _StatsPanel(),
                  ],
                ),
              ),
            ),

            // ── Bottom sheet CTA (fond blanc qui remonte sur fond sombre) ────
            const _BottomCta(),
          ],
        ),
      ),
    );
  }
}

// ── Badge ANPEJ ─────────────────────────────────────────────────────────────
// Sur fond sombre : fond semi-transparent blanc, point vert, texte clair
class _AnpejBadge extends StatelessWidget {
  const _AnpejBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp14,
        vertical: AppDimensions.sp6,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBorder, // blanc 10% — subtil sur fond forêt
        border: Border.all(color: AppColors.darkBorder),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary400, // Point vert ANPEJ
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.sp8),
          Text(
            // 'ANPEJ · GUICHET UNIQUE',
            'SIME · V2',
            style: AppTextStyles.eyebrow.copyWith(
              color: AppColors.darkTextPrimary, // Texte blanc sur fond sombre
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats panel ──────────────────────────────────────────────────────────────
// Card légèrement plus claire que le fond (darkSurfaceCard) avec bordure subtile
class _StatsPanel extends StatelessWidget {
  const _StatsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceCard, // #1A2412 — légèrement plus clair que le fond
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
                  value: '48k+',
                  label: 'Jeunes inscrits',
                  progress: 0.72,
                  color: AppColors.primary400,   // Vert ANPEJ
                  delta: '↑ +12% ce mois',
                ),
              ),
              SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: _StatCard(
                  value: '3 200',
                  label: 'Offres actives',
                  progress: 0.55,
                  color: AppColors.accent500,    // Jaune ANPEJ
                  delta: '↑ +8% ce mois',
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.sp16),
          Wrap(
            spacing: AppDimensions.sp8,
            runSpacing: AppDimensions.sp8,
            children: [
              _ServicePill(label: 'Emploi salarié',  color: AppColors.primary400,   isActive: true),
              _ServicePill(label: 'Formation',        color: AppColors.bleuANPEJ,    isActive: false),
              _ServicePill(label: 'Auto-emploi',      color: AppColors.secondary400, isActive: false),
              _ServicePill(label: 'Migration int.',   color: AppColors.violetANPEJ,  isActive: false),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
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
        // Légèrement transparent blanc — reste dans l'univers sombre
        color: AppColors.darkBorder,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.sp8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.darkBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppDimensions.sp6),
          Text(
            delta,
            style: AppTextStyles.labelXSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service pill ──────────────────────────────────────────────────────────────
// Sur fond sombre : pills subtiles, la pill active (Emploi salarié) ressort en vert
class _ServicePill extends StatelessWidget {
  const _ServicePill({
    required this.label,
    required this.color,
    this.isActive = false,
  });

  final String label;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp12,
        vertical: AppDimensions.sp6,
      ),
      decoration: BoxDecoration(
        // Active : légère teinte de la couleur du service
        // Inactive : transparent avec bordure subtile
        color: isActive ? color.withAlpha(40) : Colors.transparent,
        border: Border.all(
          color: isActive ? color.withAlpha(120) : AppColors.darkBorder,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isActive ? color : AppColors.darkTextSecondary,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ── Bottom CTA sheet ──────────────────────────────────────────────────────────
// Fond blanc qui "remonte" visuellement sur le fond sombre — contraste fort
// intentionnel, comme dans le design du PDF (slide 1/19)
class _BottomCta extends StatelessWidget {
  const _BottomCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp24, AppDimensions.sp20,
        AppDimensions.sp24, AppDimensions.sp32,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface, // Blanc pur — rupture nette avec le héro sombre
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral800.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, -8),
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
          const SizedBox(height: AppDimensions.sp20),

          // Titre et sous-titre (textes sombres sur fond blanc)
          Text(
            'Commencer maintenant',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: AppDimensions.sp4),
          Text(
            'Créez votre dossier gratuitement en 3 étapes',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppDimensions.sp20),

          // CTA principal — marron institutionnel (ElevatedButton du thème)
          SButton(
            label: 'Créer mon compte',
            onPressed: () => context.push(AppRoutes.register),
            variant: SButtonVariant.primary,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: AppDimensions.sp12),

          // CTA secondaire — outline marron (OutlinedButton du thème)
          SButton(
            label: "J'ai déjà un compte",
            onPressed: () => context.push(AppRoutes.login),
            variant: SButtonVariant.outline,
          ),
        ],
      ),
    );
  }
}