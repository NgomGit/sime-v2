import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/widgets/empty_state.dart';
import 'package:sime_v2/features/offres/presentation/widgets/offre_card.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

import '../../domain/entities/offre_entity.dart';
import '../providers/external_offers_notifier.dart';
import '../providers/job_offers_notifier.dart';
import '../providers/offres_provider.dart';
import '../providers/training_offers_notifier.dart';

class OffresScreen extends ConsumerStatefulWidget {
  const OffresScreen({super.key});

  @override
  ConsumerState<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends ConsumerState<OffresScreen> {
  final _searchController = TextEditingController();

  static const _filters = [
    (label: 'Tous', type: null),
    (label: 'Emploi', type: OffreType.emploi),
    (label: 'Externes', type: OffreType.externe),
    (label: 'Formation', type: OffreType.formation),
  ];

  @override
  void initState() {
    super.initState();
    // Premier chargement offline-first des deux sources après le premier frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobOffersNotifierProvider.notifier).ensureLoaded();
      ref.read(trainingOffersNotifierProvider.notifier).ensureLoaded();
      ref.read(externalOffersNotifierProvider.notifier).ensureLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(jobOffersNotifierProvider.notifier).loadOffers(silent: true),
      ref.read(trainingOffersNotifierProvider.notifier).loadOffers(silent: true),
      ref.read(externalOffersNotifierProvider.notifier).loadOffers(silent: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final offres = ref.watch(offresListProvider);
    final jobs = ref.watch(jobOffersNotifierProvider);
    final trainings = ref.watch(trainingOffersNotifierProvider);
    final externals = ref.watch(externalOffersNotifierProvider);
    final filter = ref.watch(offresFilterProvider);

    final hasAnyData = jobs.hasData || trainings.hasData || externals.hasData;
    final isLoading =
        (jobs.isLoading || trainings.isLoading || externals.isLoading) &&
            !hasAnyData;
    final isSyncing =
        jobs.isSyncing || trainings.isSyncing || externals.isSyncing;
    final isOffline =
        jobs.isOffline || trainings.isOffline || externals.isOffline;
    final errorMessage =
        jobs.errorMessage ?? trainings.errorMessage ?? externals.errorMessage;
    final hasError = errorMessage != null && !hasAnyData;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _SearchHeader(
              controller: _searchController,
              count: offres.length,
              onChanged: (value) => ref
                  .read(offresFilterProvider.notifier)
                  .update((s) => s.copyWith(query: value)),
            ),
            _FilterChips(
              selectedType: filter.type,
              filters: _filters,
              onSelected: (type) => ref
                  .read(offresFilterProvider.notifier)
                  .update((s) => s.copyWith(type: type, clearType: type == null)),
            ),

            // Bandeau de statut offline / synchronisation.
            _StatusBanner(
              isOffline: isOffline && hasAnyData,
              isSyncing: isSyncing,
              lastUpdated: jobs.lastUpdated ?? trainings.lastUpdated,
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary400,
                child: _buildBody(
                  isLoading: isLoading,
                  hasError: hasError,
                  errorMessage: errorMessage,
                  offres: offres,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool hasError,
    required String? errorMessage,
    required List<OffreEntity> offres,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary800),
      );
    }

    if (hasError) {
      return _ErrorList(
        message: errorMessage ?? 'Une erreur est survenue',
        onRetry: _refresh,
      );
    }

    if (offres.isEmpty) {
      // ListView pour que le pull-to-refresh reste disponible même à vide.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          EmptyState(),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      itemCount: offres.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.sp10),
        child: OffreCard(offre: offres[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search header
// ─────────────────────────────────────────────────────────────────────────────
class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.count,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int count;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20,
        AppDimensions.sp16,
        AppDimensions.sp20,
        AppDimensions.sp20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offres',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sp8,
                  vertical: AppDimensions.sp4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent500.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.accent500.withAlpha(60)),
                ),
                child: Text(
                  '$count disponible${count > 1 ? 's' : ''}',
                  style: AppTextStyles.labelXSmall.copyWith(
                    color: AppColors.accent500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sp14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white.withAlpha(100),
                        size: AppDimensions.iconMD,
                      ),
                      const SizedBox(width: AppDimensions.sp8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onChanged: onChanged,
                          textInputAction: TextInputAction.search,
                          cursorColor: AppColors.accent500,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkTextPrimary,
                          ),

                          decoration: InputDecoration(
  isDense: true,
  filled: false,                  // ← désactive le remplissage du thème
  fillColor: Colors.transparent,  // ceinture + bretelles
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  contentPadding: EdgeInsets.zero, // optionnel, colle mieux au parent
  hintText: 'Poste, structure...',
  hintStyle: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.darkTextHint,
  ),
),
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            controller.clear();
                            onChanged('');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withAlpha(120),
                            size: AppDimensions.iconSM,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chips
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedType,
    required this.filters,
    required this.onSelected,
  });

  final OffreType? selectedType;
  final List<({String label, OffreType? type})> filters;
  final ValueChanged<OffreType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20,
        0,
        AppDimensions.sp20,
        AppDimensions.sp16,
      ),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sp6),
          itemBuilder: (ctx, i) {
            final f = filters[i];
            final isSelected = selectedType == f.type;

            return GestureDetector(
              onTap: () => onSelected(f.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sp14,
                  vertical: AppDimensions.sp6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary400
                      : Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary400
                        : Colors.white.withAlpha(30),
                    width: isSelected
                        ? AppDimensions.borderMedium
                        : AppDimensions.borderThin,
                  ),
                ),
                child: Text(
                  f.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.darkTextSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status banner (offline / sync) — feedback offline-first non bloquant.
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.isOffline,
    required this.isSyncing,
    required this.lastUpdated,
  });

  final bool isOffline;
  final bool isSyncing;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final visible = isOffline || isSyncing;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical: AppDimensions.sp8,
              ),
              color: isSyncing
                  ? AppColors.primary100
                  : AppColors.accent500.withAlpha(30),
              child: Row(
                children: [
                  if (isSyncing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary800,
                      ),
                    )
                  else
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: AppDimensions.iconSM,
                      color: AppColors.secondary800,
                    ),
                  const SizedBox(width: AppDimensions.sp8),
                  Expanded(
                    child: Text(
                      isSyncing
                          ? 'Synchronisation des offres...'
                          : 'Hors ligne — offres enregistrées affichées',
                      style: AppTextStyles.labelXSmall.copyWith(
                        color: isSyncing
                            ? AppColors.primary800
                            : AppColors.secondary800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state (scrollable so pull-to-refresh works).
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorList extends StatelessWidget {
  const _ErrorList({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.sp32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 32),
                ),
                const SizedBox(height: AppDimensions.sp20),
                Text(
                  'Impossible de charger les offres',
                  style: AppTextStyles.headingSmall
                      .copyWith(color: AppColors.neutral800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sp8),
                Text(
                  message,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.neutral500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sp24),
                SizedBox(
                  height: AppDimensions.buttonHeightSM,
                  child: Material(
                    color: AppColors.primary400,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                    child: InkWell(
                      onTap: onRetry,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.sp24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded,
                                size: AppDimensions.iconSM,
                                color: AppColors.white),
                            SizedBox(width: AppDimensions.sp8),
                            Text('Réessayer',
                                style: AppTextStyles.buttonSmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
