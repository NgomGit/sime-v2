// features/rendezvous/presentation/widgets/rdv_status_badge.dart
import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/widgets/s_status_badge.dart';
import 'package:sime_v2/features/rendezvous/domain/entities/rdv_entity.dart';

/// Badge de statut d'un rendez-vous — source unique du mapping
/// [RdvStatus] → (couleur, libellé), partagée entre l'écran Agenda
/// (`rendezvous_screen.dart`) et la carte "Prochain rendez-vous" du tableau
/// de bord (`dashboard_home_screen.dart`) pour éviter que les deux dérivent
/// avec des libellés différents pour le même statut.
class RdvStatusBadge extends StatelessWidget {
  const RdvStatusBadge({super.key, required this.status, required this.rawStatus});

  final RdvStatus status;

  /// Valeur brute `statusRdv` de l'API — utilisée comme libellé de secours
  /// si [status] vaut [RdvStatus.unknown] (voir [RdvStatus.fromRaw]).
  final String rawStatus;

  (SStatusVariant, String) get _info => switch (status) {
        RdvStatus.pending => (SStatusVariant.warning, 'En attente'),
        RdvStatus.accepted => (SStatusVariant.success, 'Confirmé'),
        RdvStatus.refused => (SStatusVariant.error, 'Refusé'),
        RdvStatus.cancelled => (SStatusVariant.error, 'Annulé'),
        RdvStatus.completed => (SStatusVariant.neutral, 'Terminé'),
        RdvStatus.rescheduled => (SStatusVariant.info, 'Reprogrammé'),
        RdvStatus.unknown => (SStatusVariant.neutral, rawStatus.isEmpty ? 'Statut inconnu' : rawStatus),
      };

  @override
  Widget build(BuildContext context) {
    final (variant, label) = _info;
    return SStatusBadge(label: label, variant: variant);
  }
}
