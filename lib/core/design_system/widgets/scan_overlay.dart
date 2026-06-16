// core/ui/widgets/scanner_overlay.dart

import 'package:flutter/material.dart';

/// Draws a semi-transparent dark overlay with a transparent rectangular
/// cutout in the center — the correct way to do a "hole" in Flutter.
///
/// Uses [CustomPainter] with [BlendMode.clear] on a [saveLayer] — this is
/// the only reliable approach. [ColorFiltered] does NOT create real cutouts.
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLine;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cutoutWidth = screenWidth * 0.9;
    const cutoutHeight = 220.0;
    const cornerRadius = 16.0;

    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _scanLine,
        builder: (context, _) {
          return CustomPaint(
            painter: _OverlayPainter(
              cutoutWidth: cutoutWidth,
              cutoutHeight: cutoutHeight,
              cornerRadius: cornerRadius,
              scanLineProgress: _scanLine.value,
            ),
          );
        },
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.cutoutWidth,
    required this.cutoutHeight,
    required this.cornerRadius,
    required this.scanLineProgress,
  });

  final double cutoutWidth;
  final double cutoutHeight;
  final double cornerRadius;
  final double scanLineProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: cutoutWidth,
        height: cutoutHeight,
      ),
      Radius.circular(cornerRadius),
    );

    // ── Dark overlay with cutout ────────────────────────────────────────────
    canvas.saveLayer(Offset.zero & size, Paint());

    // 1. Draw full dark overlay
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.65),
    );

    // 2. Punch out the cutout with BlendMode.clear
    canvas.drawRRect(cutoutRect, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    // ── Corner brackets ─────────────────────────────────────────────────────
    _drawCorners(canvas, cutoutRect.outerRect);

    // ── Animated scan line ───────────────────────────────────────────────────
    final scanY =
        cutoutRect.outerRect.top +
        cutoutRect.outerRect.height * scanLineProgress;

    canvas.drawLine(
      Offset(cutoutRect.outerRect.left + 12, scanY),
      Offset(cutoutRect.outerRect.right - 12, scanY),
      Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.8)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawCorners(Canvas canvas, Rect rect) {
    const length = 24.0;
    const thickness = 3.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final corners = [
      // Top-left
      [rect.topLeft, rect.topLeft + const Offset(length, 0)],
      [rect.topLeft, rect.topLeft + const Offset(0, length)],
      // Top-right
      [rect.topRight, rect.topRight + const Offset(-length, 0)],
      [rect.topRight, rect.topRight + const Offset(0, length)],
      // Bottom-left
      [rect.bottomLeft, rect.bottomLeft + const Offset(length, 0)],
      [rect.bottomLeft, rect.bottomLeft + const Offset(0, -length)],
      // Bottom-right
      [rect.bottomRight, rect.bottomRight + const Offset(-length, 0)],
      [rect.bottomRight, rect.bottomRight + const Offset(0, -length)],
    ];

    for (final pair in corners) {
      canvas.drawLine(pair[0], pair[1], paint);
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.scanLineProgress != scanLineProgress;
}
