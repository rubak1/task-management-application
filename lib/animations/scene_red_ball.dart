import 'dart:math';
import 'package:flutter/material.dart';

class SceneRedBall extends StatefulWidget {
  final bool isActive;
  final bool reducedMotion;

  const SceneRedBall({
    super.key,
    required this.isActive,
    required this.reducedMotion,
  });

  @override
  State<SceneRedBall> createState() => _SceneRedBallState();
}

class _SceneRedBallState extends State<SceneRedBall> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.isActive && !widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SceneRedBall oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !widget.reducedMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      if (_controller.isAnimating) _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reducedMotion) {
      return Container(
        color: const Color(0xFF060103),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RedBallPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RedBallPainter extends CustomPainter {
  final double progress;

  _RedBallPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep black/crimson background
    final bgPaint = Paint()..color = const Color(0xFF050103);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final center = Offset(size.width * 0.5, size.height * 0.38);
    final baseRadius = min(size.width, size.height) * 0.36;

    // 2. Ambient Red Glow (Subtle & Darkened per prompt)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x35FF1053),
          const Color(0x15990033),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.8));
    canvas.drawCircle(center, baseRadius * 1.8, glowPaint);

    // 3. Morphing Organic 3D Sphere Wavy Layers
    final path = Path();
    const int pointsCount = 48;
    for (int i = 0; i <= pointsCount; i++) {
      final angle = (i / pointsCount) * 2 * pi;
      // Multi-frequency wave deformation
      final wave1 = sin(angle * 3 + progress * 2 * pi) * (baseRadius * 0.08);
      final wave2 = cos(angle * 5 - progress * 4 * pi) * (baseRadius * 0.04);
      final r = baseRadius + wave1 + wave2;

      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Shading with 3D spherical gradient
    final sphereShader = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      colors: [
        const Color(0xFFE6004C).withValues(alpha: 0.65),
        const Color(0xFF880026).withValues(alpha: 0.50),
        const Color(0xFF220008).withValues(alpha: 0.85),
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    final spherePaint = Paint()..shader = sphereShader;
    canvas.drawPath(path, spherePaint);

    // High contrast neon rim stroke
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = RadialGradient(
        center: const Alignment(0.4, 0.4),
        colors: [
          Colors.transparent,
          const Color(0x66FF1053),
          const Color(0x99FFFFFF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.1));
    canvas.drawPath(path, strokePaint);

    // 4. Dark Vignette Overlay
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.45),
          Colors.black.withValues(alpha: 0.90),
        ],
        stops: const [0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _RedBallPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
