// features/dossier/presentation/widgets/candidature_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_shimer.dart';
import 'package:sime_v2/features/besoin/presentation/providers/my_subscriptions_notifier.dart';
import 'package:sime_v2/features/besoin/presentation/widgets/express_besoin_button.dart';
import 'package:sime_v2/features/besoin/presentation/widgets/subscription_actions_sheet.dart';
import 'package:sime_v2/features/besoin/presentation/widgets/subscription_card.dart';

/// Onglet « Candidatures » de Mon dossier — liste des besoins sollicités
/// (souscriptions) du candidat, servie par [mySubscriptionsNotifierProvider]
/// (offline-first, même source que la section « Mes besoins » de l'accueil).
class CandidaturesTab extends ConsumerStatefulWidget {
  const CandidaturesTab({super.key});

  @override
  ConsumerState<CandidaturesTab> createState() => _CandidaturesTabState();
}

class _CandidaturesTabState extends ConsumerState<CandidaturesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mySubscriptionsNotifierProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mySubscriptionsNotifierProvider);
    final notifier = ref.read(mySubscriptionsNotifierProvider.notifier);

    if (state.isLoading && !state.hasData) {
      return const _CandidatureSkeleton();
    }

    if (state.errorMessage != null && !state.hasData) {
      return _CandidatureError(
        message: state.errorMessage!,
        onRetry: notifier.loadSubscriptions,
      );
    }

    if (!state.hasData) {
      return const _CandidatureEmpty();
    }

    return RefreshIndicator(
      color: AppColors.secondary800,
      onRefresh: notifier.loadSubscriptions,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        children: [
          if (state.isShowingStaleData)
            Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.sp12),
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.sp10, horizontal: AppDimensions.sp12),
              decoration: BoxDecoration(
                color: AppColors.accent100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: AppDimensions.iconSM, color: AppColors.accent800),
                  const SizedBox(width: AppDimensions.sp8),
                  Expanded(
                    child: Text(
                      'Mode hors-ligne · données en cache',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent800),
                    ),
                  ),
                ],
              ),
            ),
          ...state.subscriptions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sp10),
              child: SubscriptionCard(
                key: ValueKey(s.id),
                subscription: s,
                onTap: () => showSubscriptionActions(context, ref, s),
                onMore: () => showSubscriptionActions(context, ref, s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidatureSkeleton extends StatelessWidget {
  const _CandidatureSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: List.generate(
        3,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.sp10),
          child: SShimmer(
              width: double.infinity, height: 120, radius: AppDimensions.radiusLG),
        ),
      ),
    );
  }
}

class _CandidatureError extends StatelessWidget {
  const _CandidatureError({required this.message, required this.onRetry});
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
            Text('Impossible de charger vos besoins',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800)),
            const SizedBox(height: AppDimensions.sp8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500),
            ),
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

class _CandidatureEmpty extends StatelessWidget {
  const _CandidatureEmpty();

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
              decoration: const BoxDecoration(
                  color: AppColors.secondary100, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.assignment_outlined,
                  size: 32, color: AppColors.secondary600),
            ),
            const SizedBox(height: AppDimensions.sp16),
            Text('Aucun besoin sollicité',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800)),
            const SizedBox(height: AppDimensions.sp6),
            Text(
              'Exprimez un besoin auprès du Guichet Unique pour suivre son traitement ici.',
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
