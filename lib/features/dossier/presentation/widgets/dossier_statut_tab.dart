import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/core/design_system/widgets/s_status_badge.dart';
import 'package:sime_v2/features/dossier/presentation/providers/dossier_detail_state.dart';
import 'package:sime_v2/features/dossier/presentation/widgets/candidature_item_card.dart';

class DossierStatutTab extends StatelessWidget {
  const DossierStatutTab(
      {super.key, required this.state, this.onSeeAllCandidaturesPressed});

  final DossierDetailState state;

  final dynamic onSeeAllCandidaturesPressed;

  @override
  Widget build(BuildContext context) {
    if (state.dossier == null) {
      return const Center(child: Text('Aucun dossier actif'));
    }
    final d = state.dossier!;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        // Carte d'état Sombre (Identique à votre maquette HTML)
        SCard(
          isDark: true,
          padding: const EdgeInsets.all(AppDimensions.sp16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SStatusBadge(label: 'En traitement'),
                  const Spacer(),
                  Text(
                    '#${d.referenceNumber}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.darkTextHint),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sp12),
              Text(
                'Emploi salarié',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.white, fontSize: 14),
              ),
              Text(
                'Pôle Formation-Insertion · Dakar Plateau',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.darkTextSecondary),
              ),
              const SizedBox(height: AppDimensions.sp16),
              // Progression
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progression',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.darkTextHint)),
                  Text('${d.progressPercent}%',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary400)),
                ],
              ),
              const SizedBox(height: AppDimensions.sp6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: d.progressRatio,
                  minHeight: 4,
                  backgroundColor: Colors.white.withAlpha(20),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary400),
                ),
              ),
              const SizedBox(height: AppDimensions.sp8),
              // Indicateurs d'étapes (Dots colorés)
              Row(
                children: List.generate(d.totalSteps, (i) {
                  Color c;
                  if (i < d.currentStep - 1) {
                    c = AppColors.primary400; // Étapes passées (Vert #27B060)
                  } else if (i == d.currentStep - 1) {
                    c = AppColors
                        .accent500; // Étape actuelle (Orange/Jaune #F9A825)
                  } else {
                    c = Colors.white.withAlpha(25); // Étapes futures
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
                'Étape ${d.currentStep}/${d.totalSteps} · Entretien conseiller — M. Diallo',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.darkTextHint, fontSize: 9),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.sp20),

        // Aperçu des candidatures imbriquées
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mes candidatures', style: AppTextStyles.headingSmall),
            Text('Voir tout',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary400)),
            // SLinkButton(
            //     label: 'Voir tout', onPressed: onSeeAllCandidaturesPressed),
          ],
        ),
        const SizedBox(height: AppDimensions.sp10),
        ...state.candidatures.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sp8),
              child: CandidatureItemCard(offre: c),
            )),
        // HistoriqueTab(state: state),
        const SizedBox(height: AppDimensions.sp10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Historique', style: AppTextStyles.headingSmall),
            Text('Voir tout',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary400)),
          ],
        ),
        const SizedBox(height: AppDimensions.sp10),
        SCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.neutral100),
            itemBuilder: (context, index) {
              final item = state.history[index];

              // Sélection du style d'icône basé sur le type
              final (bg, iconColor, icon) = switch (item.type) {
                1 => (
                    const Color(0xFFEAF6EE),
                    const Color(0xFF1B5E20),
                    Icons.check
                  ),
                2 => (
                    const Color(0xFFE3F2FD),
                    const Color(0xFF0C447C),
                    Icons.calendar_today_outlined
                  ),
                _ => (
                    const Color(0xFFF5F4F0),
                    const Color(0xFF8A8A85),
                    Icons.person_add_alt_1_outlined
                  ),
              };

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: bg, borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: Icon(icon, color: iconColor, size: 14),
                    ),
                    const SizedBox(width: AppDimensions.sp12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: AppTextStyles.labelMedium
                                  .copyWith(fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(item.subtitle,
                              style: AppTextStyles.caption.copyWith(
                                  fontSize: 9, color: AppColors.neutral400)),
                        ],
                      ),
                    ),
                    Text(item.date,
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 9, color: AppColors.neutral300)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
