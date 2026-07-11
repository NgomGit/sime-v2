// features/auth/presentation/screens/splash_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/providers/auth_check_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Le logo apparaît en premier, avec un léger "overshoot" et une rotation subtile
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _logoRotation = Tween<double>(begin: -0.06, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // L'anneau lumineux se dilate juste derrière le logo
    _ringScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.6, curve: Curves.easeOut),
      ),
    );
    _ringFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.3, curve: Curves.easeIn),
      ),
    );

    // Le titre glisse légèrement vers le haut en apparaissant
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );
    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _listenToAuthCheck();
  }

  void _listenToAuthCheck() {
    ref.listenManual(
      authCheckProvider,
      (previous, next) async {
        if (next.hasValue) {
          await Future.delayed(const Duration(milliseconds: 1800));
          if (!mounted) return;

          final status = next.requireValue;
          if (status == AuthStatus.authenticated) {
            context.go(AppRoutes.dashboard);
          } else {
            context.go(AppRoutes.login);
          }
        }
      },
      fireImmediately:
          true, // ← gère le cas où la valeur est déjà résolue au moment de l'écoute
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary50, AppColors.background],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Formes de fond décoratives, positionnées relativement à l'écran
            Positioned(
              top: -size.width * 0.35,
              left: -size.width * 0.3,
              child: _BlurBlob(
                size: size.width * 0.9,
                color: AppColors.primary400.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.4,
              right: -size.width * 0.35,
              child: _BlurBlob(
                size: size.width * 0.95,
                color: AppColors.accent500.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: size.height * 0.12,
              right: -size.width * 0.2,
              child: _BlurBlob(
                size: size.width * 0.5,
                color: AppColors.secondary400.withValues(alpha: 0.10),
              ),
            ),

            // Contenu central
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo + anneau lumineux
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _ringScale.value,
                              child: Opacity(
                                opacity: _ringFade.value,
                                child: Container(
                                  width: 190,
                                  height: 190,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primary400
                                            .withValues(alpha: 0.18),
                                        AppColors.primary400
                                            .withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: _logoFade.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Transform.rotate(
                                  angle: _logoRotation.value,
                                  child: Container(
                                    width: 132,
                                    height: 132,
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary800
                                              .withValues(alpha: 0.10),
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                        ),
                                        BoxShadow(
                                          color: AppColors.primary400
                                              .withValues(alpha: 0.08),
                                          blurRadius: 40,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: const Image(
                                      image: AssetImage(
                                          'assets/images/logo_anpej.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Titre
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppColors.secondary800,
                                AppColors.primary800
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'SIME',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.white,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w800,
                                fontSize:
                                    (AppTextStyles.headingMedium.fontSize ??
                                            22) +
                                        4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Sous-titre
                      Opacity(
                        opacity: _subtitleFade.value,
                        child: Text(
                          "Système d'Information du Marché de l'Emploi",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Barre de progression + mention ANPEJ en bas
            Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _progressFade.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _GradientProgressBar(),
                        const SizedBox(height: 16),
                        Text(
                          'ANPEJ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral300,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Forme floue décorative en arrière-plan, façon "aurora" discrète.
class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

/// Barre de progression indéterminée avec dégradé vert → jaune ANPEJ.
class _GradientProgressBar extends StatefulWidget {
  const _GradientProgressBar();

  @override
  State<_GradientProgressBar> createState() => _GradientProgressBarState();
}

class _GradientProgressBarState extends State<_GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          color: AppColors.neutral100,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ProgressPainter(progress: _controller.value),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;

  _ProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width * 0.4;
    // Fait osciller la barre de gauche à droite (façon "indeterminate" fluide)
    final t = (math.sin(progress * 2 * math.pi - math.pi / 2) + 1) / 2;
    final dx = t * (size.width - barWidth);

    final rect = Rect.fromLTWH(dx, 0, barWidth, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary400, AppColors.accent500],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) => true;
}
