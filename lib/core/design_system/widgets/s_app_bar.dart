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
    final isConnected = ref.watch(connectivityStreamProvider).valueOrNull ?? true;
    final isOffline = !isConnected;

    final statusColor = isOffline ? AppColors.accent500 : AppColors.primary400;
    final backgroundColor = isOffline
        ? Color.lerp(AppColors.surface, AppColors.accent500, 0.06)!
        : AppColors.surface;

    const contentColor = AppColors.neutral800;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: statusColor.withValues(alpha: isOffline ? 0.35 : 0.0),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: leading,
        iconTheme: const IconThemeData(color: contentColor),
        title: Text(
          'SIME v2',
          style: AppTextStyles.headingSmall.copyWith(color: contentColor),
        ),
        // title: title ??
        //     Text(
        //       titleText ?? '',
        //       style: AppTextStyles.headingSmall.copyWith(color: contentColor),
        //     ),
        actions: [
          if (actions != null) ...actions!,
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: Center(
              child: _ConnectivityChip(isOffline: isOffline, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Pill-shaped connectivity status indicator shown in the app bar actions.
class _ConnectivityChip extends StatelessWidget {
  final bool isOffline;
  final Color color;

  const _ConnectivityChip({required this.isOffline, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isOffline ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isOffline ? 0.3 : 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isOffline ? _PulseDot(color: color) : _StaticDot(color: color),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              isOffline ? 'Hors ligne' : 'En ligne',
              key: ValueKey(isOffline),
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticDot extends StatelessWidget {
  final Color color;
  const _StaticDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Small breathing/pulsing dot used to signal an active offline state.
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.6);
        final opacity = 1.0 - (_controller.value * 0.5);
        return SizedBox(
          width: 12,
          height: 12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity * 0.4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                  ),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }
}