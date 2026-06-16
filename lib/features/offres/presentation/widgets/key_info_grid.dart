import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';

class KeyInfoGrid extends StatelessWidget {
  const KeyInfoGrid({super.key, required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.work_history_outlined, 'Contrat', offre.contractType?.name.toUpperCase() ?? '—'),
      (Icons.location_city_outlined, 'Lieu', offre.location),
      (Icons.school_outlined, 'Niveau', offre.educationLevel ?? '—'),
      (Icons.trending_up_outlined, 'Expérience', offre.experienceYears ?? '—'),
      if (offre.companySize != null)
        (Icons.corporate_fare_outlined, 'Effectif', offre.companySize!),
      if (offre.publishedAt != null)
        (
          Icons.calendar_today_outlined,
          'Publié le',
          DateFormat('dd MMM yyyy', 'fr').format(offre.publishedAt!)
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.sp4),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3.0,
        mainAxisSpacing: AppDimensions.sp4,
        crossAxisSpacing: AppDimensions.sp4,
        children: items
            .map((i) => _InfoTile(
                  icon: i.$1,
                  label: i.$2,
                  value: i.$3,
                ))
            .toList(),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp12, vertical: AppDimensions.sp8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        // Remplacement par le Marron institutionnel pour asseoir la structure de la donnée
        Icon(icon, size: AppDimensions.iconSM, color: AppColors.secondary600),
        const SizedBox(width: AppDimensions.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(fontSize: 9, letterSpacing: 0.5, color: AppColors.neutral500)),
              Text(value,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.neutral800, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}
