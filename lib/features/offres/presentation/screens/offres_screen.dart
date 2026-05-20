import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_card.dart';
import '../../../../core/design_system/widgets/s_tag.dart';
import '../../domain/entities/offre_entity.dart';
import '../providers/offres_provider.dart';

class OffresScreen extends ConsumerStatefulWidget {
  const OffresScreen({super.key});

  @override
  ConsumerState<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends ConsumerState<OffresScreen> {
  OffreType? _selectedType;

  static const _filters = [
    (label: 'Tous', type: null),
    (label: 'Emploi', type: OffreType.emploi),
    (label: 'Stage', type: OffreType.stage),
    (label: 'Formation', type: OffreType.formation),
    (label: 'Migration', type: OffreType.migration),
  ];

  @override
  Widget build(BuildContext context) {
    final offresValue = ref.watch(offresListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Dark header ──────────────────────────────────────────────────
            _SearchHeader(
              onFilterChanged: (type) {
                setState(() => _selectedType = type);
                ref.read(offresFilterProvider.notifier).update(
                      (s) => OffresFilter(type: type, query: s.query),
                    );
              },
            ),
            // ── Filter chips ─────────────────────────────────────────────────
            _FilterChips(
              selectedType: _selectedType,
              filters: _filters,
              onSelected: (type) {
                setState(() => _selectedType = type);
                ref.read(offresFilterProvider.notifier).update(
                      (s) => OffresFilter(type: type, query: s.query),
                    );
              },
            ),
            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: offresValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
                data: (offres) => offres.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(AppDimensions.pagePaddingH),
                        itemCount: offres.length,
                        itemBuilder: (ctx, i) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimensions.sp10),
                          child: _OffreCard(offre: offres[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({this.onFilterChanged});
  final ValueChanged<OffreType?>? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary900,
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
                'Offres d\'emploi',
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.white),
              ),
              Text(
                '3 218 disponibles',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.darkTextHint),
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
                      horizontal: AppDimensions.sp14),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Colors.white.withAlpha(100),
                          size: AppDimensions.iconMD),
                      const SizedBox(width: AppDimensions.sp8),
                      Text(
                        'Poste, entreprise...',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.darkTextHint),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sp10),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary400.withAlpha(38),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.primary400.withAlpha(64)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.tune,
                    color: AppColors.primary400, size: AppDimensions.iconMD),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      color: AppColors.primary900,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20,
        0,
        AppDimensions.sp20,
        AppDimensions.sp14,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sp14,
                  vertical: AppDimensions.sp6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary400
                      : Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary400
                        : Colors.white.withAlpha(30),
                  ),
                ),
                child: Text(
                  f.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.darkTextSecondary,
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

class _OffreCard extends StatelessWidget {
  const _OffreCard({required this.offre});
  final OffreEntity offre;

  (Color bg, Color fg, IconData icon) get _typeStyle => switch (offre.type) {
        OffreType.emploi => (
            AppColors.primary100,
            AppColors.primary800,
            Icons.work_outline
          ),
        OffreType.stage => (
            AppColors.infoBg,
            AppColors.info,
            Icons.co_present_outlined
          ),
        OffreType.formation => (
            AppColors.infoBg,
            AppColors.info,
            Icons.school_outlined
          ),
        OffreType.financement => (
            AppColors.accent100,
            AppColors.accent800,
            Icons.rocket_launch_outlined
          ),
        OffreType.migration => (
            AppColors.warningBg.withValues(alpha: 0.4),
            AppColors.accent900,
            Icons.flight_takeoff_outlined
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _typeStyle;
    final contractLabel = offre.contractType?.name.toUpperCase();

    return SCard(
      color: offre.isFeatured ? AppColors.primary50 : AppColors.white,
      borderColor: offre.isFeatured ? AppColors.primary100 : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offre.isFeatured) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sp8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.primary100),
              ),
              child: Text(
                'À la une',
                style: AppTextStyles.labelXSmall
                    .copyWith(color: AppColors.primary800),
              ),
            ),
            const SizedBox(height: AppDimensions.sp10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: fg, size: AppDimensions.iconLG),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offre.title, style: AppTextStyles.labelLarge),
                    const SizedBox(height: AppDimensions.sp4),
                    Row(
                      children: [
                        const Icon(Icons.business_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.neutral400),
                        const SizedBox(width: 3),
                        Text(offre.company, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border,
                    color: AppColors.neutral200),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          Wrap(
            spacing: AppDimensions.sp4,
            runSpacing: AppDimensions.sp4,
            children: [
              if (contractLabel != null)
                STag(
                    label: contractLabel,
                    backgroundColor: AppColors.primary100,
                    textColor: AppColors.primary800),
              STag(
                  label: offre.location,
                  backgroundColor: AppColors.neutral50,
                  textColor: AppColors.neutral600),
              if (offre.educationLevel != null)
                STag(
                    label: offre.educationLevel!,
                    backgroundColor: AppColors.infoBg,
                    textColor: AppColors.info),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.sp12),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: AppDimensions.iconXS, color: AppColors.neutral300),
              const SizedBox(width: 4),
              Text(
                'Clôture ${DateFormat('dd MMM', 'fr').format(offre.deadline)}',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                ),
                child: const Text('Postuler', style: AppTextStyles.buttonSmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.neutral200),
          SizedBox(height: AppDimensions.sp12),
          Text('Aucune offre trouvée', style: AppTextStyles.labelLarge),
          Text('Modifiez vos filtres', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
