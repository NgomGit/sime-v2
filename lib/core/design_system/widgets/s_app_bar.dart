// core/design_system/widgets/s_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/network/network_info.dart';

class SAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;

  const SAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkInfoProvider);
    // networkState.isConnected may be nullable or non-bool; treat any non-true as offline
    final isOffline = networkState.isConnected == false;

    // Define offline theme variations (e.g., sophisticated slate gray or muted amber alert)
    final backgroundColor = isOffline 
        ? AppColors.neutral800 
        : AppColors.surface;
        
    final contentColor = isOffline 
        ? AppColors.white 
        : AppColors.neutral800;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AppBar(
        backgroundColor: backgroundColor,
        elevation: isOffline ? 2 : 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: leading,
        iconTheme: IconThemeData(color: contentColor),
        title: title ?? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titleText ?? '',
              style: AppTextStyles.headingSmall.copyWith(color: contentColor),
            ),
            if (isOffline)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 10, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      'Mode hors-ligne sync.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white, 
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          if (actions != null) ...actions!,
          // Global indicators can be attached here
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
              size: 18,
              color: isOffline ? AppColors.error : AppColors.primary400,
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}