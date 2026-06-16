import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/features/offres/presentation/providers/offres_detail_provider.dart';
import 'package:sime_v2/features/offres/presentation/widgets/applied_banner.dart';

class BottomCta extends ConsumerWidget {
  const BottomCta({super.key, 
    required this.state,
    required this.onApply,
    required this.onSave,
  });
  final OffreDetailState state;
  final Future<void> Function() onApply;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final offre = state.offre;

    return Container(
      padding: EdgeInsets.fromLTRB(AppDimensions.sp20, AppDimensions.sp16,
          AppDimensions.sp20, bottom + AppDimensions.sp16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            top: BorderSide(
                color: AppColors.border, width: AppDimensions.borderThin)),
      ),
      child: state.hasApplied
          ? const AppliedBanner()
          : Row(children: [
              // Bouton Sauvegarder secondaire
              GestureDetector(
                onTap: onSave,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: offre.isSaved ? AppColors.primary100 : AppColors.neutral50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: offre.isSaved ? AppColors.primary100 : AppColors.border),
                  ),
                  child: Icon(
                    offre.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: offre.isSaved ? AppColors.primary800 : AppColors.neutral600,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sp12),
              
              // Bouton Postuler principal (Vert ANPEJ éclatant)
              Expanded(
                child: SButton(
                  onPressed: onApply, label: 'Postuler à l\'offre',
                 
                ),
              ),
            ]),
    );
  }
}


