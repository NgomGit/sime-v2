// features/besoin/presentation/widgets/dossier_progress_card.dart
import 'package:flutter/material.dart';

import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';

import '../../domain/entities/my_subscription_entity.dart';
import 'subscription_status_badge.dart';

/// Carte « dossier » sombre (fond vert forêt) reprenant la maquette du suivi de
/// dossier, mais alimentée par une souscription réelle ([MySubscriptionEntity]).
/// Affiche le besoin, la structure/offre, le statut et l'avancement projeté sur
/// le pipeline canonique (voir `MySubscriptionEntity.progress*`).
///
/// Réutilisée telle quelle sur l'accueil (dernier besoin) et dans l'onglet
/// « Statut » (carrousel horizontal des dossiers).
class DossierProgressCard extends StatelessWidget {
  const DossierProgressCard({super.key, required this.subscription, this.onTap});

  final MySubscriptionEntity subscription;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    final dotColor = statusDotColor(s.statusKind);
    final currentStepColor = s.isNegative ? AppColors.error : AppColors.accent500;

    final subtitle = [s.offreLabel, s.structureLabel]
        .where((e) => e != null && e.trim().isNotEmpty)
        .join(' · ');

    return SCard(
      isDark: true,
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusPill(label: s.statusLabel, color: dotColor),
              const Spacer(),
              if (s.reference.isNotEmpty)
                Flexible(
                  child: Text(
                    '#${s.reference}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.darkTextHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          Text(
            s.besoinLabel,
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle.isNotEmpty ? subtitle : 'Guichet Unique',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.sp16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progression',
                  style: AppTextStyles.caption.copyWith(color: AppColors.darkTextHint)),
              Text('${s.progressPercent}%',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary400)),
            ],
          ),
          const SizedBox(height: AppDimensions.sp6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: s.progressRatio,
              minHeight: 4,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(
                s.isNegative ? AppColors.error : AppColors.primary400,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sp8),
          Row(
            children: List.generate(s.progressTotalSteps, (i) {
              final Color c;
              if (i < s.progressCurrentStep - 1) {
                c = AppColors.primary400; // étape franchie
              } else if (i == s.progressCurrentStep - 1) {
                c = currentStepColor; // étape courante
              } else {
                c = Colors.white.withAlpha(25); // étape future
              }
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimensions.sp8),
          Text(
            'Étape ${s.progressCurrentStep}/${s.progressTotalSteps} · ${s.progressStepLabel}',
            style: AppTextStyles.caption.copyWith(color: AppColors.darkTextHint, fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Pastille de statut lisible sur fond sombre : point coloré + libellé blanc.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp10, vertical: AppDimensions.sp4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.sp6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelXSmall.copyWith(color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
