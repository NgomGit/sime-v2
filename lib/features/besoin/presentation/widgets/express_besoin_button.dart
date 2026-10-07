// features/besoin/presentation/widgets/express_besoin_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/features/profile/presentation/providers/profile_completion_provider.dart';
import 'package:sime_v2/features/profile/presentation/widgets/profile_completion_sheet.dart';

/// Bouton « Exprimer un besoin » avec verrou de complétion de profil intégré.
///
/// Tant que [ProfileCompletion.canExpressBesoin] est faux (sections
/// « Informations personnelles » et « Situation personnelle » incomplètes), le
/// bouton apparaît désactivé, avec une icône cadenas, et NE lance pas le
/// parcours besoin : un appui ouvre la feuille guidée de complétion de profil.
/// Une fois le profil complet, il redevient un CTA normal qui pousse la route
/// [AppRoutes.nouveauBesoin].
class ExpressBesoinButton extends ConsumerWidget {
  const ExpressBesoinButton({
    super.key,
    this.variant = SButtonVariant.primary,
    this.size = SButtonSize.large,
    this.fullWidth = true,
  });

  final SButtonVariant variant;
  final SButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = !ref.watch(
      profileCompletionProvider.select((c) => c.canExpressBesoin),
    );

    final button = SButton(
      label: 'Exprimer un besoin',
      leadingIcon:
          locked ? Icons.lock_outline_rounded : Icons.add_rounded,
      variant: variant,
      size: size,
      fullWidth: fullWidth,
      isDisabled: locked,
      onPressed: locked ? null : () => context.push(AppRoutes.nouveauBesoin),
    );

    if (!locked) return button;

    // Bouton désactivé : on capte tout de même l'appui pour expliquer, de
    // façon non bloquante, ce qu'il reste à compléter.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showProfileCompletionSheet(context),
      child: button,
    );
  }
}
