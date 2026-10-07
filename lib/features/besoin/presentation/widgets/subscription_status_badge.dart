// features/besoin/presentation/widgets/subscription_status_badge.dart
import 'package:flutter/material.dart';

import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/widgets/s_status_badge.dart';

import '../../domain/entities/my_subscription_entity.dart';

/// Mapping unique statut → variante de badge (clair). Partagé par le badge et
/// (via [statusDotColor]) par la carte de progression sombre.
SStatusVariant statusVariantOf(SubscriptionStatusKind kind) => switch (kind) {
      SubscriptionStatusKind.validated => SStatusVariant.success,
      SubscriptionStatusKind.inValidation => SStatusVariant.warning,
      SubscriptionStatusKind.returned => SStatusVariant.warning,
      SubscriptionStatusKind.suspended => SStatusVariant.warning,
      SubscriptionStatusKind.invalid => SStatusVariant.error,
      SubscriptionStatusKind.ready => SStatusVariant.info,
      SubscriptionStatusKind.forwarded => SStatusVariant.info,
      SubscriptionStatusKind.archived => SStatusVariant.neutral,
      SubscriptionStatusKind.other => SStatusVariant.neutral,
    };

/// Couleur du point de statut lisible sur le fond sombre de la carte
/// « dossier » (les fonds pâles des variantes claires n'y ressortent pas).
Color statusDotColor(SubscriptionStatusKind kind) => switch (statusVariantOf(kind)) {
      SStatusVariant.success => AppColors.primary400,
      SStatusVariant.warning => AppColors.accent500,
      SStatusVariant.error => AppColors.error,
      SStatusVariant.info => AppColors.bleuANPEJ,
      SStatusVariant.neutral => AppColors.neutral300,
    };

/// Badge de statut d'un besoin sollicité — source unique du mapping
/// (code de statut) → variante de couleur, partagée entre l'accueil et
/// l'onglet « Candidatures » (même logique que [RdvStatusBadge]).
class SubscriptionStatusBadge extends StatelessWidget {
  const SubscriptionStatusBadge({super.key, required this.subscription});

  final MySubscriptionEntity subscription;

  SStatusVariant get _variant => statusVariantOf(subscription.statusKind);

  @override
  Widget build(BuildContext context) {
    return SStatusBadge(label: subscription.statusLabel, variant: _variant);
  }
}
