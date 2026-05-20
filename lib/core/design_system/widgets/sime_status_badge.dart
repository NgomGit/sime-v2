import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_dimensions.dart';

enum SimeStatus { enAttente, enTraitement, accepte, rejete, confirme, termine, annule }

class SimeStatusBadge extends StatelessWidget {
  const SimeStatusBadge({super.key, required this.status});
  final SimeStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = switch (status) {
      SimeStatus.enAttente    => ('En attente',    AppColors.warning, const Color(0xFF795B00)),
      SimeStatus.enTraitement => ('En traitement', AppColors.warning, const Color(0xFF795B00)),
      SimeStatus.accepte      => ('Accepté',       AppColors.primary100, AppColors.primary800),
      SimeStatus.rejete       => ('Rejeté',        const Color(0xFFFFEBEE), AppColors.error),
      SimeStatus.confirme     => ('Confirmé',      AppColors.primary100, AppColors.primary800),
      SimeStatus.termine      => ('Terminé',       AppColors.neutral100, AppColors.neutral600),
      SimeStatus.annule       => ('Annulé',        const Color(0xFFFFEBEE), AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: fg, fontSize: 10)),
    );
  }
}
