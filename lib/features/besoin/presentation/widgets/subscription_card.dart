// features/besoin/presentation/widgets/subscription_card.dart
import 'package:flutter/material.dart';

import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';

import '../../domain/entities/my_subscription_entity.dart';
import 'subscription_status_badge.dart';

/// Carte d'un besoin sollicité (souscription) — réutilisée par l'accueil et
/// l'onglet « Candidatures ». Met en avant l'offre choisie, le besoin
/// (catégorie) et la structure partenaire, avec le statut courant.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
    this.onMore,
  });

  final MySubscriptionEntity subscription;
  final VoidCallback? onTap;

  /// Bouton « ⋯ » (actions Modifier / Supprimer). Masqué si `null`.
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final visual = subscription.visual;
    final title = subscription.offreLabel ?? subscription.besoinLabel;

    return SCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                alignment: Alignment.center,
                child: Icon(visual.icon, size: AppDimensions.iconMD, color: visual.color),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subscription.besoinLabel,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onMore != null)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Actions',
                    onPressed: onMore,
                    icon: const Icon(Icons.more_horiz_rounded,
                        size: AppDimensions.iconMD, color: AppColors.neutral400),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.sp10),
          Row(
            children: [
              if (subscription.structureLabel != null) ...[
                const Icon(Icons.account_balance_rounded,
                    size: AppDimensions.iconXS, color: AppColors.neutral400),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subscription.structureLabel!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.sp8),
              ] else
                const Spacer(),
              SubscriptionStatusBadge(subscription: subscription),
            ],
          ),
          if (subscription.reference.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.sp8),
            Row(
              children: [
                const Icon(Icons.tag_rounded,
                    size: AppDimensions.iconXS, color: AppColors.neutral300),
                const SizedBox(width: 3),
                Text(
                  'Réf. ${subscription.reference}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
