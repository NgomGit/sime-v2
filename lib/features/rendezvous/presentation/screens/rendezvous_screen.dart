import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_card.dart';
import '../../../../core/design_system/widgets/s_status_badge.dart';
import '../../domain/entities/rendezvous_entity.dart';
import '../providers/rendezvous_provider.dart';

class RendezVousScreen extends ConsumerWidget {
  const RendezVousScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rdvAsync = ref.watch(rendezvousListProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(),
            _CalendarStrip(selectedDate: selectedDate),
            const Divider(height: 1),
            Expanded(
              child: rdvAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
                data: (rdvs) => _TimelineView(rdvs: rdvs, selectedDate: selectedDate),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary900,
        child: const Icon(Icons.add, color: AppColors.primary400),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.sp20, AppDimensions.sp14,
        AppDimensions.sp20, AppDimensions.sp12,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mon agenda', style: AppTextStyles.headingMedium),
              Text(
                'Mai 2026 · 2 rendez-vous',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class _CalendarStrip extends ConsumerWidget {
  const _CalendarStrip({required this.selectedDate});
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show a week strip around selectedDate
    final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, 0, AppDimensions.sp20, AppDimensions.sp14,
      ),
      child: Column(
        children: [
          // Month row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'fr').format(selectedDate),
                style: AppTextStyles.labelLarge,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left, size: AppDimensions.iconMD),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.neutral800,
                  ),
                  const SizedBox(width: AppDimensions.sp4),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right, size: AppDimensions.iconMD),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.neutral800,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          // Day cells
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday = _isSameDay(day, DateTime.now());
              final isSelected = _isSameDay(day, selectedDate);
              final hasEvent = _isSameDay(day, DateTime(2026, 5, 18)) ||
                  _isSameDay(day, DateTime(2026, 5, 14));
              return GestureDetector(
                onTap: () => ref.read(selectedDateProvider.notifier).state = day,
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'fr').format(day).substring(0, 3).toUpperCase(),
                      style: AppTextStyles.labelXSmall,
                    ),
                    const SizedBox(height: AppDimensions.sp6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary400
                            : isToday
                                ? AppColors.primary900
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected || isToday
                              ? AppColors.white
                              : AppColors.neutral800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp4),
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: hasEvent ? AppColors.primary400 : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.rdvs, required this.selectedDate});
  final List<RendezVousEntity> rdvs;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    // Separate upcoming vs past for display
    final upcoming = rdvs.where((r) => r.isUpcoming).toList();
    final past     = rdvs.where((r) => !r.isUpcoming).toList();

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionLabel(label: DateFormat('EEEE dd MMMM', 'fr').format(selectedDate)),
          const SizedBox(height: AppDimensions.sp10),
          ...upcoming.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sp12),
            child: _TimelineItem(rdv: r),
          )),
        ],
        const _EmptySlot(time: '14h00'),
        if (past.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.sp16),
          const _SectionLabel(label: 'Mercredi 14 mai · passé'),
          const SizedBox(height: AppDimensions.sp10),
          ...past.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sp10),
            child: _TimelineItem(rdv: r, isPast: true),
          )),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.neutral400,
        letterSpacing: 0.5,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.rdv, this.isPast = false});
  final RendezVousEntity rdv;
  final bool isPast;

  SStatusVariant get _statusVariant => switch (rdv.status) {
    RendezVousStatus.confirmed  => SStatusVariant.success,
    RendezVousStatus.scheduled  => SStatusVariant.warning,
    RendezVousStatus.started    => SStatusVariant.info,
    RendezVousStatus.completed  => SStatusVariant.neutral,
    RendezVousStatus.cancelled  => SStatusVariant.error,
  };

  String get _statusLabel => switch (rdv.status) {
    RendezVousStatus.confirmed  => 'Confirmé',
    RendezVousStatus.scheduled  => 'Planifié',
    RendezVousStatus.started    => 'En cours',
    RendezVousStatus.completed  => 'Terminé',
    RendezVousStatus.cancelled  => 'Annulé',
  };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.65 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH\'h\'mm').format(rdv.dateTime),
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: AppDimensions.sp4),
                Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.sp12),
                  child: Container(
                    width: 2, height: 60,
                    color: isPast ? AppColors.neutral100 : AppColors.primary400.withAlpha(76),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.sp10),
          // Card
          Expanded(
            child: SCard(
              color: isPast
                  ? AppColors.neutral50
                  : rdv.status == RendezVousStatus.confirmed
                      ? AppColors.primary50
                      : AppColors.white,
              borderColor: isPast
                  ? AppColors.border
                  : rdv.status == RendezVousStatus.confirmed
                      ? AppColors.primary100
                      : AppColors.border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rdv.conseillerName.contains('Mme')
                      ? 'Session coaching CV'
                      : 'Entretien de dossier', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppDimensions.sp4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: AppDimensions.iconXS, color: AppColors.neutral400),
                      const SizedBox(width: 3),
                      Text(rdv.location, style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sp10),
                  const Divider(height: 1),
                  const SizedBox(height: AppDimensions.sp10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary800,
                        child: Text(
                          rdv.conseillerName.split(' ').map((p) => p[0]).take(2).join(),
                          style: AppTextStyles.labelXSmall.copyWith(color: AppColors.white),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sp8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rdv.conseillerName, style: AppTextStyles.labelMedium),
                          const Text('Conseiller emploi', style: AppTextStyles.caption),
                        ],
                      ),
                      const Spacer(),
                      SStatusBadge(label: _statusLabel, variant: _statusVariant),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 46,
          child: Text(time, style: AppTextStyles.labelMedium, textAlign: TextAlign.end),
        ),
        const SizedBox(width: AppDimensions.sp10),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: AppColors.neutral100,
                width: AppDimensions.borderThin,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.neutral200, size: AppDimensions.iconSM),
                const SizedBox(width: AppDimensions.sp6),
                Text('Créneau disponible', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral300)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
