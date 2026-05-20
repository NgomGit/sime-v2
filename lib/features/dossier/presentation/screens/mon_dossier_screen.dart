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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (state) => DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // ── Top Bar Blanche ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sp20,
                        vertical: AppDimensions.sp14,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mon dossier', style: AppTextStyles.headingSmall),
                              const SizedBox(height: 2),
                              Text(
                                'Dernière mise à jour · 18 mai 2026',
                                style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.more_horiz, color: AppColors.primary900, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Custom TabBar ──────────────────────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      tabBar: TabBar(
                        labelColor: AppColors.primary900,
                        unselectedLabelColor: AppColors.neutral400,
                        indicatorColor: AppColors.primary900,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 2.5,
                        labelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
                        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w500),
                        tabs: const [
                          Tab(text: 'Statut'),
                          Tab(text: 'Candidatures'),
                          Tab(text: 'Historique'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              // ── Contenu Unique Unifié sous forme de ScrollView Global ───────
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

// ── PERSISTENT TAB BAR DELEGATE ──────────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({required this.tabBar});
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}