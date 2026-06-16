// ─── App bar ──────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class OffreDetailAppBar extends StatelessWidget {
  const OffreDetailAppBar({super.key, 
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
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
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
              bg: isSaved ? AppColors.primary100 : AppColors.neutral50,
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
      child: Container(
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
