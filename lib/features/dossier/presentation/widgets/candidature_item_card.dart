// Widget Réutilisable pour l'item Candidature
import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/core/design_system/widgets/s_tag.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';

class CandidatureItemCard extends StatelessWidget {
  const CandidatureItemCard({super.key, required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    final isWave = offre.title.contains('Flutter');

    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isWave ? const Color(0xFFEAF6EE) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isWave ? Icons.phone_android : Icons.eco_outlined,
                  color: isWave ? const Color(0xFF1B5E20) : const Color(0xFF795B00),
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offre.title, style: AppTextStyles.labelLarge.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.business, size: 10, color: AppColors.neutral400),
                        const SizedBox(width: 3),
                        Text(offre.company, style: AppTextStyles.bodySmall.copyWith(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isWave) // Dot vert de notification/sélection sur Wave
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(color: AppColors.accent500, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp10),
          Wrap(
            spacing: AppDimensions.sp4,
            children: [
              STag(
                label: isWave ? 'CDI' : 'GRATUIT',
                backgroundColor: const Color(0xFFEAF6EE),
                textColor: const Color(0xFF1B5E20),
              ),
              STag(
                label: offre.educationLevel ?? '6 semaines',
                backgroundColor: isWave ? const Color(0xFFE3F2FD) : const Color(0xFFF1EFE8),
                textColor: isWave ? const Color(0xFF0C447C) : const Color(0xFF444441),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp10),
          const Divider(height: 1, color: AppColors.neutral100),
          const SizedBox(height: AppDimensions.sp8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 10, color: AppColors.neutral300),
                  const SizedBox(width: 3),
                  Text(isWave ? 'Postulé le 10 mai' : 'Postulé le 5 mai', style: AppTextStyles.caption.copyWith(fontSize: 9)),
                ],
              ),
              STag(
                label: isWave ? 'Présélectionné' : 'En attente',
                backgroundColor: isWave ? const Color(0xFFEAF6EE) : const Color(0xFFFFF8E1),
                textColor: isWave ? const Color(0xFF1B5E20) : const Color(0xFF795B00),
              ),
            ],
          ),
        ],
      ),
    );
  }
}