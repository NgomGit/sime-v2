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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header sur fond blanc (écran intérieur post-connexion)
            const _PageHeader(),
            _CalendarStrip(selectedDate: selectedDate),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: rdvAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary800,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Erreur: $e',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
                data: (rdvs) => _TimelineView(
                  rdvs: rdvs,
                  selectedDate: selectedDate,
                ),
              ),
            ),
          ],
        ),
      ),
      // FAB — marron institutionnel + icône vert ANPEJ
      // Cohérence avec FloatingActionButtonTheme dans AppTheme
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.secondary800,
        foregroundColor: AppColors.surface,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page header
// ─────────────────────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, AppDimensions.sp14,
        AppDimensions.sp20, AppDimensions.sp12,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mon agenda',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.neutral800,
                ),
              ),
              Text(
                'Mai 2026 · 2 rendez-vous',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar strip
// ─────────────────────────────────────────────────────────────────────────────
// Jour sélectionné → marron institutionnel secondary800
//   Un rendez-vous ANPEJ est un acte institutionnel — le marron ancre la date.
// Jour actuel (aujourd'hui non sélectionné) → secondary100 (marron doux)
//   Distinctif du jour sélectionné sans entrer en compétition.
// Point d'événement → vert primary400 (il y a une opportunité ce jour)
class _CalendarStrip extends ConsumerWidget {
  const _CalendarStrip({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, AppDimensions.sp4,
        AppDimensions.sp20, AppDimensions.sp16,
      ),
      child: Column(
        children: [
          // Ligne mois + chevrons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'fr').format(selectedDate),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.neutral800,
                ),
              ),
              Row(
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    onTap: () {
                      ref.read(selectedDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 7));
                    },
                  ),
                  const SizedBox(width: AppDimensions.sp4),
                  _NavButton(
                    icon: Icons.chevron_right,
                    onTap: () {
                      ref.read(selectedDateProvider.notifier).state =
                          selectedDate.add(const Duration(days: 7));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),

          // Cellules des jours
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday = _isSameDay(day, DateTime.now());
              final isSelected = _isSameDay(day, selectedDate);
              final hasEvent = _isSameDay(day, DateTime(2026, 5, 18)) ||
                  _isSameDay(day, DateTime(2026, 5, 14));

              // Couleurs du cercle :
              //   sélectionné   → secondary800 (marron fort)
              //   aujourd'hui   → secondary100 (marron doux)
              //   autre         → transparent
              final circleBg = isSelected
                  ? AppColors.secondary800
                  : isToday
                      ? AppColors.secondary100
                      : Colors.transparent;

              final dayNumColor = isSelected
                  ? AppColors.white
                  : isToday
                      ? AppColors.secondary800
                      : AppColors.neutral800;

              return GestureDetector(
                onTap: () =>
                    ref.read(selectedDateProvider.notifier).state = day,
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'fr')
                          .format(day)
                          .substring(0, 3)
                          .toUpperCase(),
                      style: AppTextStyles.labelXSmall.copyWith(
                        color: isSelected
                            ? AppColors.secondary800
                            : AppColors.neutral400,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: circleBg,
                        shape: BoxShape.circle,
                        // Bordure subtile sur le jour actuel non sélectionné
                        border: isToday && !isSelected
                            ? Border.all(
                                color: AppColors.secondary400,
                                width: AppDimensions.borderThin,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: dayNumColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sp4),
                    // Point événement — vert ANPEJ (opportunité ce jour)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: hasEvent
                            ? AppColors.primary400
                            : Colors.transparent,
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

// Bouton de navigation chevron — fond neutral50 avec bordure
class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: AppDimensions.iconSM, color: AppColors.neutral800),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline view
// ─────────────────────────────────────────────────────────────────────────────
class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.rdvs, required this.selectedDate});

  final List<RendezVousEntity> rdvs;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final upcoming = rdvs.where((r) => r.isUpcoming).toList();
    final past = rdvs.where((r) => !r.isUpcoming).toList();

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionLabel(
            label: DateFormat('EEEE dd MMMM', 'fr').format(selectedDate),
          ),
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

// Label de section — neutre discret
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline item
// ─────────────────────────────────────────────────────────────────────────────
// Couleurs sémantiques :
//   Ligne verticale active  → secondary400 (marron doux — fil institutionnel)
//   Ligne verticale passée  → neutral100 (neutre — moment révolu)
//   Card RDV confirmé       → secondary50 fond + secondary100 bordure
//     (un RDV confirmé = engagement institutionnel → marron doux)
//   Avatar conseiller       → secondary800 fond (marron institutionnel)
//   Card passée             → neutral50 fond (désaturé, en retrait)
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.rdv, this.isPast = false});

  final RendezVousEntity rdv;
  final bool isPast;

  SStatusVariant get _statusVariant => switch (rdv.status) {
        RendezVousStatus.confirmed => SStatusVariant.success,
        RendezVousStatus.scheduled => SStatusVariant.warning,
        RendezVousStatus.started   => SStatusVariant.info,
        RendezVousStatus.completed => SStatusVariant.neutral,
        RendezVousStatus.cancelled => SStatusVariant.error,
      };

  String get _statusLabel => switch (rdv.status) {
        RendezVousStatus.confirmed => 'Confirmé',
        RendezVousStatus.scheduled => 'Planifié',
        RendezVousStatus.started   => 'En cours',
        RendezVousStatus.completed => 'Terminé',
        RendezVousStatus.cancelled => 'Annulé',
      };

  @override
  Widget build(BuildContext context) {
    final isConfirmed = rdv.status == RendezVousStatus.confirmed;

    return Opacity(
      opacity: isPast ? 0.65 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne heure + ligne verticale
          SizedBox(
            width: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat("HH'h'mm").format(rdv.dateTime),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppDimensions.sp4),
                Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.sp12),
                  child: Container(
                    width: 2, height: 60,
                    decoration: BoxDecoration(
                      // Passé : neutre / Actif : marron doux (fil institutionnel)
                      color: isPast
                          ? AppColors.neutral100
                          : AppColors.secondary400.withAlpha(80),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.sp10),

          // Card du rendez-vous
          Expanded(
            child: SCard(
              // Passé       : neutral50 (en retrait, désaturé)
              // Confirmé    : secondary50 (marron très doux — engagement)
              // Autre statut : surface blanc standard
              color: isPast
                  ? AppColors.neutral50
                  : isConfirmed
                      ? AppColors.secondary50
                      : AppColors.surface,
              borderColor: isPast
                  ? AppColors.border
                  : isConfirmed
                      ? AppColors.secondary100
                      : AppColors.border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rdv.conseillerName.contains('Mme')
                        ? 'Session coaching CV'
                        : 'Entretien de dossier',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppDimensions.iconXS,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rdv.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sp10),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: AppDimensions.sp10),
                  Row(
                    children: [
                      // Avatar conseiller — marron institutionnel
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.secondary800,
                        child: Text(
                          rdv.conseillerName
                              .split(' ')
                              .map((p) => p[0])
                              .take(2)
                              .join(),
                          style: AppTextStyles.labelXSmall.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sp8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rdv.conseillerName,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.neutral800,
                            ),
                          ),
                          Text(
                            'Conseiller emploi',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SStatusBadge(
                        label: _statusLabel,
                        variant: _statusVariant,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Empty slot
// ─────────────────────────────────────────────────────────────────────────────
// Créneau disponible — invitation subtile à prendre un RDV
// Bordure en tirets visuellement suggérée via border neutral200
class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 46,
          child: Text(
            time,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.neutral400,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: AppDimensions.sp10),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: AppColors.neutral200,
                width: AppDimensions.borderThin,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.neutral300,
                  size: AppDimensions.iconSM,
                ),
                const SizedBox(width: AppDimensions.sp6),
                Text(
                  'Créneau disponible',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral300,
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