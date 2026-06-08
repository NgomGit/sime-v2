import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/app_colors.dart';
import '../tokens/app_dimensions.dart';


class SShimmer extends StatefulWidget {
  const SShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius,
  });
  final double width;
  final double height;
  final double? radius;

  @override
  State<SShimmer> createState() => _SShimmerState();
}

class _SShimmerState extends State<SShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(widget.radius ?? AppDimensions.radiusSM),
          gradient: LinearGradient(
            stops: const [0.0, 0.5, 1.0],
            colors: const [
              AppColors.neutral50,
              AppColors.neutral100,
              AppColors.neutral50,
            ],
            transform: _SlideTransform(_anim.value),
          ),
        ),
      ),
    );
  }
}

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.pct);
  final double pct;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * pct, 0, 0);
}