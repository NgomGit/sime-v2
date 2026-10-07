// features/besoin/presentation/widgets/subscription_actions_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_status_dialog.dart';

import '../../domain/entities/my_subscription_entity.dart';
import '../providers/my_subscriptions_notifier.dart';

/// Ouvre la feuille d'actions d'un besoin : Modifier / Supprimer.
///
/// Les deux actions ne sont proposées que si le besoin est encore modifiable
/// ([MySubscriptionEntity.isEditable]) ; sinon la feuille explique pourquoi.
Future<void> showSubscriptionActions(
  BuildContext context,
  WidgetRef ref,
  MySubscriptionEntity subscription,
) async {
  HapticFeedback.selectionClick();
  final action = await showModalBottomSheet<_SubscriptionAction>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ActionsSheet(subscription: subscription),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _SubscriptionAction.edit:
      await context.push(AppRoutes.nouveauBesoin, extra: subscription);
    case _SubscriptionAction.delete:
      await _confirmAndDelete(context, ref, subscription);
  }
}

enum _SubscriptionAction { edit, delete }

Future<void> _confirmAndDelete(
  BuildContext context,
  WidgetRef ref,
  MySubscriptionEntity subscription,
) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeleteConfirmSheet(subscription: subscription),
  );
  if (confirmed != true || !context.mounted) return;

  HapticFeedback.mediumImpact();
  final messenger = ScaffoldMessenger.of(context);
  final (ok, message) = await ref
      .read(mySubscriptionsNotifierProvider.notifier)
      .deleteSubscription(subscription.id);
  if (!context.mounted) return;

  if (ok) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.neutral800,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary400, size: AppDimensions.iconMD),
              const SizedBox(width: AppDimensions.sp10),
              Expanded(
                child: Text('Besoin supprimé',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
              ),
            ],
          ),
        ),
      );
  } else {
    AppStatusDialog.show(
      context,
      type: StatusDialogType.error,
      title: 'Suppression impossible',
      message: message ?? "Une erreur s'est produite. Veuillez réessayer.",
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feuille d'actions
// ─────────────────────────────────────────────────────────────────────────────
class _ActionsSheet extends StatelessWidget {
  const _ActionsSheet({required this.subscription});
  final MySubscriptionEntity subscription;

  @override
  Widget build(BuildContext context) {
    final editable = subscription.isEditable;
    final visual = subscription.visual;

    return _SheetFrame(
      children: [
        Row(
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
                    subscription.offreLabel ?? subscription.besoinLabel,
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subscription.reference.isNotEmpty)
                    Text(
                      'Réf. ${subscription.reference}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp16),
        if (!editable)
          Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.sp12),
            padding: const EdgeInsets.all(AppDimensions.sp12),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: AppDimensions.iconSM, color: AppColors.neutral400),
                const SizedBox(width: AppDimensions.sp8),
                Expanded(
                  child: Text(
                    'Ce besoin est déjà pris en charge (${subscription.statusLabel.toLowerCase()}) : '
                    'il ne peut plus être modifié ni supprimé.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                  ),
                ),
              ],
            ),
          ),
        _ActionTile(
          icon: Icons.edit_rounded,
          label: 'Modifier le besoin',
          color: AppColors.secondary800,
          background: AppColors.secondary50,
          enabled: editable,
          onTap: () => Navigator.of(context).pop(_SubscriptionAction.edit),
        ),
        const SizedBox(height: AppDimensions.sp8),
        _ActionTile(
          icon: Icons.delete_outline_rounded,
          label: 'Supprimer le besoin',
          color: AppColors.error,
          background: AppColors.errorBg,
          enabled: editable,
          onTap: () => Navigator.of(context).pop(_SubscriptionAction.delete),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sp12, vertical: AppDimensions.sp12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: AppDimensions.iconSM, color: color),
                ),
                const SizedBox(width: AppDimensions.sp12),
                Expanded(
                  child: Text(label,
                      style: AppTextStyles.labelMedium.copyWith(color: color)),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: AppDimensions.iconMD, color: AppColors.neutral300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation de suppression
// ─────────────────────────────────────────────────────────────────────────────
class _DeleteConfirmSheet extends StatelessWidget {
  const _DeleteConfirmSheet({required this.subscription});
  final MySubscriptionEntity subscription;

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.errorBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 28),
          ),
        ),
        const SizedBox(height: AppDimensions.sp14),
        Text(
          'Supprimer ce besoin ?',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp6),
        Text(
          '« ${subscription.offreLabel ?? subscription.besoinLabel} » sera retiré de '
          'votre dossier. Cette action est définitive.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppDimensions.sp20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppDimensions.inputHeight),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annuler',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800)),
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppDimensions.inputHeight),
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: AppDimensions.iconSM, color: AppColors.white),
                label: Text('Supprimer',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Cadre commun des feuilles : fond arrondi, poignée, marges sûres.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.sp10,
            AppDimensions.pagePaddingH,
            AppDimensions.sp16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.sp16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
