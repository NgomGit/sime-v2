import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/features/dossier/presentation/providers/dossier_detail_state.dart';


class HistoriqueTab extends StatelessWidget {
  const HistoriqueTab({super.key, required this.state});
  final DossierDetailState state;

  @override
  Widget build(BuildContext context) {
    return HistoriqueContent(state: state);
  }
}

class HistoriqueContent extends StatelessWidget {
  const HistoriqueContent({
    super.key,
    required this.state,
    this.maxCount = double.infinity,
  });

  final DossierDetailState state;
  
  final double maxCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        const Text('Historique du dossier', style: AppTextStyles.headingSmall),
        const SizedBox(height: AppDimensions.sp10),
        SCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: maxCount != double.infinity ? maxCount.toInt() : state.history.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.neutral100),
            itemBuilder: (context, index) {
              final item = state.history[index];
              
              // Sélection du style d'icône basé sur le type
              final (bg, iconColor, icon) = switch(item.type) {
                1 => (const Color(0xFFEAF6EE), const Color(0xFF1B5E20), Icons.check),
                2 => (const Color(0xFFE3F2FD), const Color(0xFF0C447C), Icons.calendar_today_outlined),
                _ => (const Color(0xFFF5F4F0), const Color(0xFF8A8A85), Icons.person_add_alt_1_outlined),
              };
    
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: Icon(icon, color: iconColor, size: 14),
                    ),
                    const SizedBox(width: AppDimensions.sp12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: AppTextStyles.labelMedium.copyWith(fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(item.subtitle, style: AppTextStyles.caption.copyWith(fontSize: 9, color: AppColors.neutral400)),
                        ],
                      ),
                    ),
                    Text(item.date, style: AppTextStyles.caption.copyWith(fontSize: 9, color: AppColors.neutral300)),
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