import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';

class SOverlayLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final double blurOpacity;

  const SOverlayLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.blurOpacity = 0.8,
  });

  @override
  State<SOverlayLoader> createState() => _SOverlayLoaderState();
}

class _SOverlayLoaderState extends State<SOverlayLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SOverlayLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading) ...[
          // Barrière anti-clics avec fondu subtil
          ModalBarrier(
            dismissible: false,
            color: AppColors.darkSurface.withValues(alpha: widget.blurOpacity),
          ),
          // Loader graphique moderne centralisé
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anneau externe : Couleur institutionnelle (Marron)
                    Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: 0.7,
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary400),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    // Anneau interne asynchrone : Accent ANPEJ (Vert)
                    Transform.rotate(
                      angle: -_controller.value * 4 * math.pi,
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          value: 0.35,
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}