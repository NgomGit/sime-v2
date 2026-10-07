// features/dossier/presentation/widgets/dossier_statut_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/core/design_system/widgets/s_shimer.dart';
import 'package:sime_v2/features/besoin/domain/entities/my_subscription_entity.dart';
import 'package:sime_v2/features/besoin/presentation/providers/my_subscriptions_notifier.dart';
import 'package:sime_v2/features/besoin/presentation/widgets/express_besoin_button.dart';
import 'package:sime_v2/features/besoin/presentation/widgets/dossier_progress_card.dart';
import 'package:sime_v2/features/besoin/presentation/widgets/subscription_status_badge.dart';

/// Onglet « Statut » — carrousel horizontal des dossiers (souscriptions) du
/// candidat : une carte de progression par besoin, défilable de gauche à
/// droite, avec le détail du dossier sélectionné en dessous.
class DossierStatutTab extends ConsumerStatefulWidget {
  const DossierStatutTab({super.key});

  @override
  ConsumerState<DossierStatutTab> createState() => _DossierStatutTabState();
}

class _DossierStatutTabState extends ConsumerState<DossierStatutTab> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mySubscriptionsNotifierProvider.notifier).ensureLoaded();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mySubscriptionsNotifierProvider);
    final notifier = ref.read(mySubscriptionsNotifierProvider.notifier);

    if (state.isLoading && !state.hasData) {
      return const _StatutSkeleton();
    }
    if (state.errorMessage != null && !state.hasData) {
      return _StatutError(message: state.errorMessage!, onRetry: notifier.loadSubscriptions);
    }
    if (!state.hasData) {
      return const _StatutEmpty();
    }

    // Les plus récents d'abord (id décroissant), pour aligner avec « le dernier
    // besoin » mis en avant sur l'accueil.
    final items = [...state.subscriptions]..sort((a, b) => b.id.compareTo(a.id));
    final safePage = _page.clamp(0, items.length - 1);
    final selected = items[safePage];

    return RefreshIndicator(
      color: AppColors.secondary800,
      onRefresh: notifier.loadSubscriptions,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Suivi de dossier',
                    style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800)),
                if (items.length > 1)
                  Text(
                    '${safePage + 1}/${items.length}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral400),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sp10),

          // Carrousel horizontal des dossiers
          SizedBox(
            height: 196,
            child: PageView.builder(
              controller: _controller,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp6),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: DossierProgressCard(subscription: items[i]),
                  ),
                );
              },
            ),
          ),

          if (items.length > 1) ...[
            const SizedBox(height: AppDimensions.sp12),
            _PageDots(count: items.length, active: safePage),
          ],

          const SizedBox(height: AppDimensions.sp20),

          // Détail du dossier sélectionné
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
            child: _DossierDetails(subscription: selected),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Détails du dossier sélectionné
// ─────────────────────────────────────────────────────────────────────────────
class _DossierDetails extends StatelessWidget {
  const _DossierDetails({required this.subscription});
  final MySubscriptionEntity subscription;

  @override
  Widget build(BuildContext context) {
    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Détail du dossier',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800)),
              const Spacer(),
              SubscriptionStatusBadge(subscription: subscription),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.sp12),
          _DetailRow(
              icon: Icons.grid_view_rounded,
              label: 'Besoin sollicité',
              value: subscription.besoinLabel),
          if (subscription.offreLabel != null)
            _DetailRow(
                icon: Icons.assignment_outlined,
                label: 'Offre de service',
                value: subscription.offreLabel!),
          if (subscription.structureLabel != null)
            _DetailRow(
                icon: Icons.account_balance_rounded,
                label: 'Structure',
                value: subscription.structureLabel!),
          if (subscription.reference.isNotEmpty)
            _DetailRow(
                icon: Icons.tag_rounded,
                label: 'Référence',
                value: subscription.reference),
          _DetailRow(
            icon: Icons.timelapse_rounded,
            label: 'Étape',
            value:
                '${subscription.progressCurrentStep}/${subscription.progressTotalSteps} · ${subscription.progressStepLabel}',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.sp12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimensions.iconSM, color: AppColors.neutral400),
          const SizedBox(width: AppDimensions.sp10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
                const SizedBox(height: 1),
                Text(value,
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Indicateur de pages (dots)
// ─────────────────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondary800 : AppColors.neutral200,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// États
// ─────────────────────────────────────────────────────────────────────────────
class _StatutSkeleton extends StatelessWidget {
  const _StatutSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: const [
        SShimmer(width: 140, height: 18),
        SizedBox(height: AppDimensions.sp16),
        SShimmer(width: double.infinity, height: 180, radius: AppDimensions.radiusLG),
        SizedBox(height: AppDimensions.sp20),
        SShimmer(width: double.infinity, height: 160, radius: AppDimensions.radiusLG),
      ],
    );
  }
}

class _StatutError extends StatelessWidget {
  const _StatutError({required this.message, required this.onRetry});
  final String message;
  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: AppDimensions.sp14),
            Text('Impossible de charger le dossier',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800)),
            const SizedBox(height: AppDimensions.sp8),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: AppDimensions.sp20),
            SButton(
              label: 'Réessayer',
              variant: SButtonVariant.outline,
              fullWidth: false,
              onPressed: () => onRetry(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatutEmpty extends StatelessWidget {
  const _StatutEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  const BoxDecoration(color: AppColors.secondary100, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.folder_open_outlined,
                  size: 32, color: AppColors.secondary600),
            ),
            const SizedBox(height: AppDimensions.sp16),
            Text('Aucun dossier en cours',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800)),
            const SizedBox(height: AppDimensions.sp6),
            Text(
              'Exprimez un besoin auprès du Guichet Unique pour ouvrir un dossier.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
            ),
            const SizedBox(height: AppDimensions.sp20),
            const ExpressBesoinButton(fullWidth: false),
          ],
        ),
      ),
    );
  }
}
