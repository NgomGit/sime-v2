import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sime_v2/core/design_system/widgets/s_shimer.dart';
import 'package:sime_v2/features/offres/presentation/providers/offres_detail_provider.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_card.dart';
import '../../../../core/design_system/widgets/s_tag.dart';
import '../../domain/entities/offre_entity.dart';


class OffreDetailScreen extends ConsumerWidget {
  const OffreDetailScreen({super.key, required this.offreId});

  final String offreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(offreDetailProvider(offreId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: async.when(
          loading: () => const _Skeleton(),
          error: (e, _) => _ErrorBody(
            message: e.toString(),
            onRetry: () => ref.invalidate(offreDetailProvider(offreId)),
          ),
          data: (state) => _Body(offreId: offreId, state: state),
        ),
      ),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _Body extends ConsumerWidget {
  const _Body({required this.offreId, required this.state});

  final String offreId;
  final OffreDetailState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(offreDetailProvider(offreId).notifier);
    final offre = state.offre;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            _AppBar(
              title: offre.title,
              isSaved: offre.isSaved,
              onBack: () => Navigator.of(context).pop(),
              onSave: notifier.toggleSave,
              onShare: () {},
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.sp20,
                AppDimensions.pagePaddingH,
                120,
              ),
              sliver: SliverList.list(children: [
                // ── Hero header ────────────────────────────────────────
                _HeroHeader(offre: offre),
                const SizedBox(height: AppDimensions.sp16),

                // ── Tags ───────────────────────────────────────────────
                _TagsRow(offre: offre),
                const SizedBox(height: AppDimensions.sp16),

                // ── Key info grid ──────────────────────────────────────
                _KeyInfoGrid(offre: offre),
                const SizedBox(height: AppDimensions.sp24),

                // ── Description ────────────────────────────────────────
                _Section(
                  title: 'Description du poste',
                  child: _ExpandableText(text: offre.description ?? ''),
                ),
                const SizedBox(height: AppDimensions.sp24),

                // ── Missions ───────────────────────────────────────────
                if (offre.missions!.isNotEmpty) ...[
                  _Section(
                    title: 'Missions principales',
                    child: _BulletList(
                      items: offre.missions ?? [],
                      dotColor: AppColors.primary400,
                      dotBg: AppColors.primary100,
                      icon: Icons.arrow_forward_rounded,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Requirements ───────────────────────────────────────
                if (offre.requirements!.isNotEmpty) ...[
                  _Section(
                    title: 'Profil recherché',
                    child: _BulletList(
                      items: offre.requirements ?? [],
                      dotColor: AppColors.primary800,
                      dotBg: AppColors.primary100,
                      icon: Icons.check_rounded,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Benefits ───────────────────────────────────────────
                if (offre.benefits!.isNotEmpty ) ...[
                  _Section(
                    title: 'Ce que nous offrons',
                    child: _BenefitsGrid(items: offre.benefits ?? []),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Recruitment steps ──────────────────────────────────
                if (offre.recruitmentSteps!.isNotEmpty) ...[
                  _Section(
                    title: 'Processus de recrutement',
                    child: _RecruitmentStepper(steps: offre.recruitmentSteps ?? []),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Company ────────────────────────────────────────────
                if (offre.companyDescription != null) ...[
                  _CompanyCard(offre: offre),
                  const SizedBox(height: AppDimensions.sp24),
                ],

                // ── Similar offres ─────────────────────────────────────
                if (state.similarOffres.isNotEmpty) ...[
                  _SimilarSection(
                    offres: state.similarOffres,
                    onTap: (id) => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => OffreDetailScreen(offreId: id),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ],
        ),

        // ── Sticky CTA ─────────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomCta(
            state: state,
            onApply: notifier.apply,
            onSave: notifier.toggleSave,
          ),
        ),
      ],
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.title,
    required this.isSaved,
    required this.onBack,
    required this.onSave,
    required this.onShare,
  });

  final String title;
  final bool isSaved;
  final VoidCallback onBack, onSave, onShare;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.border,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp16),
        child: Row(
          children: [
            _CircleBtn(icon: Icons.arrow_back_rounded, onTap: onBack),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppDimensions.sp8),
            _CircleBtn(icon: Icons.share_outlined, onTap: onShare),
            const SizedBox(width: AppDimensions.sp8),
            _CircleBtn(
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              onTap: onSave,
              bg: isSaved ? AppColors.primary50 : AppColors.neutral50,
              border: isSaved ? AppColors.primary100 : AppColors.border,
              color: isSaved ? AppColors.primary800 : AppColors.neutral600,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.bg,
    this.border,
    this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? bg, border, color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg ?? AppColors.neutral50,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: Border.all(color: border ?? AppColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon,
            size: AppDimensions.iconSM, color: color ?? AppColors.neutral600),
      ),
    );
  }
}

// ─── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.work_outline_rounded,
              size: AppDimensions.iconXL, color: AppColors.primary800),
        ),
        const SizedBox(width: AppDimensions.sp14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured badge
              if (offre.isFeatured) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sp8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent100,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border:
                        Border.all(color: AppColors.accent500.withAlpha(80)),
                  ),
                  child: Text(
                    '⭐ À la une',
                    style: AppTextStyles.labelXSmall
                        .copyWith(color: const Color(0xFF795B00)),
                  ),
                ),
                const SizedBox(height: AppDimensions.sp6),
              ],
              Text(offre.title, style: AppTextStyles.headingMedium),
              const SizedBox(height: AppDimensions.sp6),
              // Company + location
              Row(children: [
                const Icon(Icons.business_outlined,
                    size: AppDimensions.iconXS, color: AppColors.neutral400),
                const SizedBox(width: 4),
                Text(offre.company, style: AppTextStyles.bodyMedium),
                const SizedBox(width: AppDimensions.sp6),
                _Dot(),
                const SizedBox(width: AppDimensions.sp6),
                const Icon(Icons.location_on_outlined,
                    size: AppDimensions.iconXS, color: AppColors.neutral400),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(offre.location,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: AppDimensions.sp8),
              // Applicants + ref
              Row(children: [
                const Icon(Icons.group_outlined,
                    size: AppDimensions.iconXS, color: AppColors.neutral300),
                const SizedBox(width: 4),
                Text('${offre.applicantCount} candidatures',
                    style: AppTextStyles.caption),
                if (offre.referenceNumber != null) ...[
                  const SizedBox(width: AppDimensions.sp10),
                  _Dot(),
                  const SizedBox(width: AppDimensions.sp6),
                  Text('Réf: ${offre.referenceNumber}',
                      style: AppTextStyles.caption),
                ],
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
            color: AppColors.neutral200, shape: BoxShape.circle),
      );
}

// ─── Tags row ─────────────────────────────────────────────────────────────────

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.sp6,
      runSpacing: AppDimensions.sp6,
      children: [
        if (offre.contractType != null)
          STag(
            label: offre.contractType!.name.toUpperCase(),
            backgroundColor: AppColors.primary100,
            textColor: AppColors.primary800,
          ),
        if (offre.educationLevel != null)
          STag(
            label: offre.educationLevel!,
            backgroundColor: AppColors.infoBg,
            textColor: AppColors.info,
          ),
        if (offre.experienceYears != null)
          STag(
            label: offre.experienceYears!,
            backgroundColor: AppColors.neutral50,
            textColor: AppColors.neutral600,
          ),
        if (offre.sector != null)
          STag(
            label: offre.sector!,
            backgroundColor: const Color(0xFFEDE7F6),
            textColor: const Color(0xFF4527A0),
          ),
        // Deadline chip
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sp8, vertical: AppDimensions.sp4),
          decoration: BoxDecoration(
            color:
                offre.daysLeft <= 5 ? AppColors.errorBg : AppColors.warningBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              Icons.access_time_rounded,
              size: 9,
              color: offre.daysLeft <= 5
                  ? AppColors.error
                  : const Color(0xFF795B00),
            ),
            const SizedBox(width: 3),
            Text(
              offre.daysLeft > 0
                  ? 'J-${offre.daysLeft} · ${DateFormat('dd MMM', 'fr').format(offre.deadline)}'
                  : 'Clôturé',
              style: AppTextStyles.labelXSmall.copyWith(
                color: offre.daysLeft <= 5
                    ? AppColors.error
                    : const Color(0xFF795B00),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─── Key info grid ────────────────────────────────────────────────────────────

class _KeyInfoGrid extends StatelessWidget {
  const _KeyInfoGrid({required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (
        Icons.work_history_outlined,
        'Contrat',
        offre.contractType?.name.toUpperCase() ?? '—'
      ),
      (Icons.location_city_outlined, 'Lieu', offre.location),
      (Icons.school_outlined, 'Niveau', offre.educationLevel ?? '—'),
      (Icons.trending_up_outlined, 'Expérience', offre.experienceYears ?? '—'),
      if (offre.companySize != null)
        (Icons.corporate_fare_outlined, 'Effectif', offre.companySize!),
      if (offre.publishedAt != null)
        (
          Icons.calendar_today_outlined,
          'Publié le',
          DateFormat('dd MMM yyyy', 'fr').format(offre.publishedAt!)
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.sp4),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3.0,
        mainAxisSpacing: AppDimensions.sp4,
        crossAxisSpacing: AppDimensions.sp4,
        children: items
            .map((i) => _InfoTile(
                  icon: i.$1,
                  label: i.$2,
                  value: i.$3,
                ))
            .toList(),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp12, vertical: AppDimensions.sp8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Icon(icon, size: AppDimensions.iconXS, color: AppColors.primary600),
        const SizedBox(width: AppDimensions.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(fontSize: 8, letterSpacing: 0.5)),
              Text(value,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.neutral800, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Section wrapper ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTextStyles.headingSmall),
      const SizedBox(height: AppDimensions.sp12),
      child,
    ]);
  }
}

// ─── Expandable text ──────────────────────────────────────────────────────────

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});
  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedCrossFade(
        crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 220),
        firstChild: Text(widget.text,
            style: AppTextStyles.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis),
        secondChild: Text(widget.text, style: AppTextStyles.bodyMedium),
      ),
      const SizedBox(height: AppDimensions.sp8),
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_expanded ? 'Voir moins' : 'Lire la suite',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary400)),
          const SizedBox(width: 3),
          Icon(
            _expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: AppDimensions.iconSM,
            color: AppColors.primary400,
          ),
        ]),
      ),
    ]);
  }
}

// ─── Bullet list ──────────────────────────────────────────────────────────────

class _BulletList extends StatelessWidget {
  const _BulletList({
    required this.items,
    required this.dotColor,
    required this.dotBg,
    required this.icon,
  });
  final List<String> items;
  final Color dotColor, dotBg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SCard(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(
        children: items.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: e.key < items.length - 1 ? AppDimensions.sp10 : 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(color: dotBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(icon, size: 9, color: dotColor),
              ),
              const SizedBox(width: AppDimensions.sp10),
              Expanded(child: Text(e.value, style: AppTextStyles.bodySmall)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Benefits grid ────────────────────────────────────────────────────────────

class _BenefitsGrid extends StatelessWidget {
  const _BenefitsGrid({required this.items});
  final List<String> items;

  static const _icons = [
    Icons.payments_outlined,
    Icons.health_and_safety_outlined,
    Icons.laptop_outlined,
    Icons.home_work_outlined,
    Icons.school_outlined,
    Icons.emoji_events_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.sp8,
        crossAxisSpacing: AppDimensions.sp8,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (_, i) {
        final icon = _icons[i % _icons.length];
        return Container(
          padding: const EdgeInsets.all(AppDimensions.sp10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: AppDimensions.iconXS, color: AppColors.primary800),
            ),
            const SizedBox(width: AppDimensions.sp8),
            Expanded(
              child: Text(items[i],
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.neutral800, fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        );
      },
    );
  }
}

// ─── Recruitment stepper ──────────────────────────────────────────────────────

class _RecruitmentStepper extends StatelessWidget {
  const _RecruitmentStepper({required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return SCard(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final isLast = e.key == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Node + line
              SizedBox(
                width: 28,
                child: Column(children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        color: AppColors.primary900, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      '${e.key + 1}',
                      style: AppTextStyles.labelXSmall
                          .copyWith(color: AppColors.primary400),
                    ),
                  ),
                  if (!isLast)
                    Container(
                        width: 1.5,
                        height: 28,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: AppColors.neutral100),
                ]),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.sp10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value, style: AppTextStyles.labelMedium),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Company card ─────────────────────────────────────────────────────────────

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.offre});
  final OffreEntity offre;

  @override
  Widget build(BuildContext context) {
    return SCard(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            alignment: Alignment.center,
            child: const Icon(Icons.corporate_fare_outlined,
                size: AppDimensions.iconMD, color: AppColors.primary800),
          ),
          const SizedBox(width: AppDimensions.sp12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offre.company, style: AppTextStyles.labelLarge),
              if (offre.companySize != null)
                Text(offre.companySize!, style: AppTextStyles.bodySmall),
            ]),
          ),
        ]),
        if (offre.companyDescription != null) ...[
          const SizedBox(height: AppDimensions.sp12),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.sp12),
          Text(offre.companyDescription!, style: AppTextStyles.bodySmall),
        ],
      ]),
    );
  }
}

// ─── Similar offres ───────────────────────────────────────────────────────────

class _SimilarSection extends StatelessWidget {
  const _SimilarSection({required this.offres, required this.onTap});
  final List<OffreEntity> offres;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Offres similaires', style: AppTextStyles.headingSmall),
          Text('Voir tout',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary400)),
        ],
      ),
      const SizedBox(height: AppDimensions.sp12),
      ...offres.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sp8),
            child: _SimilarCard(offre: o, onTap: () => onTap(o.id)),
          )),
    ]);
  }
}

class _SimilarCard extends StatelessWidget {
  const _SimilarCard({required this.offre, required this.onTap});
  final OffreEntity offre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.sp14),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.border)),
          alignment: Alignment.center,
          child: const Icon(Icons.work_outline,
              size: AppDimensions.iconSM, color: AppColors.neutral400),
        ),
        const SizedBox(width: AppDimensions.sp12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(offre.title,
                style: AppTextStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${offre.company} · ${offre.location}',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: AppDimensions.sp6),
            Wrap(spacing: AppDimensions.sp4, children: [
              if (offre.contractType != null)
                STag(
                  label: offre.contractType!.name.toUpperCase(),
                  backgroundColor: AppColors.primary100,
                  textColor: AppColors.primary800,
                ),
              if (offre.educationLevel != null)
                STag(
                  label: offre.educationLevel!,
                  backgroundColor: AppColors.infoBg,
                  textColor: AppColors.info,
                ),
            ]),
          ]),
        ),
        const Icon(Icons.chevron_right,
            size: AppDimensions.iconSM, color: AppColors.neutral200),
      ]),
    );
  }
}

// ─── Sticky bottom CTA ────────────────────────────────────────────────────────

class _BottomCta extends ConsumerWidget {
  const _BottomCta({
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
          ? _AppliedBanner()
          : Row(children: [
              // Save button
              GestureDetector(
                onTap: onSave,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: AppDimensions.buttonHeight,
                  height: AppDimensions.buttonHeight,
                  decoration: BoxDecoration(
                    color: state.offre.isSaved
                        ? AppColors.primary50
                        : AppColors.neutral50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                    border: Border.all(
                      color: state.offre.isSaved
                          ? AppColors.primary100
                          : AppColors.border,
                      width: AppDimensions.borderMedium,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    state.offre.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: state.offre.isSaved
                        ? AppColors.primary800
                        : AppColors.neutral500,
                    size: AppDimensions.iconMD,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sp12),
              // Apply button
              Expanded(
                child:
                    _ApplyButton(isLoading: state.isApplying, onTap: onApply),
              ),
            ]),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: Material(
        color: AppColors.primary900,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary400))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Postuler maintenant',
                        style: AppTextStyles.buttonLarge),
                    SizedBox(width: AppDimensions.sp8),
                    Icon(Icons.arrow_forward_rounded,
                        size: AppDimensions.iconSM,
                        color: AppColors.primary400),
                  ]),
          ),
        ),
      ),
    );
  }
}

class _AppliedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_outline_rounded,
            color: AppColors.primary800, size: AppDimensions.iconMD),
        const SizedBox(width: AppDimensions.sp10),
        Text('Candidature envoyée',
            style:
                AppTextStyles.labelLarge.copyWith(color: AppColors.primary800)),
      ]),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SShimmer(width: 36, height: 36, radius: AppDimensions.radiusSM),
          SizedBox(height: AppDimensions.sp24),
          Row(children: [
            SShimmer(
                width: 58, height: 58, radius: AppDimensions.radiusMD),
            SizedBox(width: AppDimensions.sp14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SShimmer(width: double.infinity, height: 20),
                    SizedBox(height: AppDimensions.sp8),
                    SShimmer(width: 160, height: 13),
                    SizedBox(height: AppDimensions.sp6),
                    SShimmer(width: 120, height: 11),
                  ]),
            ),
          ]),
          SizedBox(height: AppDimensions.sp20),
          Row(children: [
            SShimmer(width: 56, height: 24, radius: AppDimensions.radiusFull),
            SizedBox(width: AppDimensions.sp8),
            SShimmer(width: 72, height: 24, radius: AppDimensions.radiusFull),
            SizedBox(width: AppDimensions.sp8),
            SShimmer(width: 80, height: 24, radius: AppDimensions.radiusFull),
          ]),
          SizedBox(height: AppDimensions.sp24),
          SShimmer(
              width: double.infinity,
              height: 96,
              radius: AppDimensions.radiusLG),
          SizedBox(height: AppDimensions.sp16),
          SShimmer(
              width: double.infinity,
              height: 130,
              radius: AppDimensions.radiusLG),
          SizedBox(height: AppDimensions.sp16),
          SShimmer(
              width: double.infinity,
              height: 130,
              radius: AppDimensions.radiusLG),
        ]),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.sp32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppColors.errorBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 32),
          ),
          const SizedBox(height: AppDimensions.sp20),
          const Text('Une erreur est survenue',
              style: AppTextStyles.headingSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.sp8),
          Text(message,
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.sp24),
          SizedBox(
            height: AppDimensions.buttonHeightSM,
            child: Material(
              color: AppColors.primary900,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.sp24),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.refresh_rounded,
                        size: AppDimensions.iconSM,
                        color: AppColors.primary400),
                    SizedBox(width: AppDimensions.sp8),
                    Text('Réessayer', style: AppTextStyles.buttonMedium),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
