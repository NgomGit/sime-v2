import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/dossier/presentation/widgets/candidature_tab.dart';
import 'package:sime_v2/features/dossier/presentation/widgets/dossier_statut_tab.dart';
import 'package:sime_v2/features/dossier/presentation/widgets/historique_tab.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../providers/dossier_detail_provider.dart';

class MonDossierScreen extends ConsumerWidget {
  const MonDossierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(dossierDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: stateAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.secondary800,
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              'Erreur : $e',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ),
          data: (state) => DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // ── Top bar ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sp20,
                      vertical: AppDimensions.sp14,
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mon dossier',
                              style: AppTextStyles.headingSmall.copyWith(
                                color: AppColors.neutral800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dernière mise à jour · 18 mai 2026',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Bouton "···" — fond secondary100 (marron doux)
                        // Les actions sur le dossier sont institutionnelles
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.secondary100,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSM),
                            border: Border.all(color: AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.more_horiz,
                            color: AppColors.secondary800, // marron institutionnel
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Tab bar persistant ────────────────────────────────────────
                // labelColor / indicatorColor → secondary800 (marron)
                // L'onglet actif représente la vue institutionnelle en cours,
                // pas un contenu positif — le marron est sémantiquement correct.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      labelColor: AppColors.secondary800,
                      unselectedLabelColor: AppColors.neutral400,
                      indicatorColor: AppColors.secondary800,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 2.5,
                      dividerColor: AppColors.border,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Statut'),
                        Tab(text: 'Candidatures'),
                        Tab(text: 'Historique'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  DossierStatutTab(state: state),
                  CandidaturesTab(state: state),
                  HistoriqueTab(state: state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sliver tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surface,
      // Séparateur bas visible quand la tab bar est épinglée et que le contenu
      // défile dessous — évite l'effet "flottant sans ancrage"
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: tabBar),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}