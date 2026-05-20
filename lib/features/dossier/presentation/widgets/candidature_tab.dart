import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/features/dossier/presentation/providers/dossier_detail_state.dart';
import 'package:sime_v2/features/dossier/presentation/widgets/candidature_item_card.dart';

class CandidaturesTab extends StatelessWidget {
  const CandidaturesTab({super.key, required this.state});
  final DossierDetailState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      itemCount: state.candidatures.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sp10),
          child: CandidatureItemCard(offre: state.candidatures[index]),
        );
      },
    );
  }
}
