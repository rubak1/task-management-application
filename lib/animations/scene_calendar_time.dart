import 'dart:math';
import 'package:flutter/material.dart';

class SceneCalendarTime extends StatefulWidget {
  final bool isActive;
  final bool reducedMotion;

  const SceneCalendarTime({
    super.key,
    required this.isActive,
    required this.reducedMotion,
  });

  @override
  State<SceneCalendarTime> createState() => _SceneCalendarTimeState();
}

class _SceneCalendarTimeState extends State<SceneCalendarTime> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    if (widget.isActive && !widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SceneCalendarTime oldWidget) {
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
      return Container(color: const Color(0xFF060609));
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CalendarTimePainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _CalendarTimePainter extends CustomPainter {
  final double progress;

  _CalendarTimePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep cosmic dark background
    final bgPaint = Paint()..color = const Color(0xFF060609);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final center = Offset(size.width * 0.5, size.height * 0.42);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.12);

    final goldBeadPaint = Paint()..color = const Color(0xFFFFD166);
    final beadGlowPaint = Paint()
      ..color = const Color(0x55FFD166)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Orbital Rings
    final List<double> radii = [80, 140, 210, 290];
    for (int i = 0; i < radii.length; i++) {
      final r = radii[i];
      canvas.drawCircle(center, r, ringPaint);

      // Orbital chrono marker
      final speedFactor = (i % 2 == 0) ? 1.0 : -1.0;
      final angle = (progress * 2 * pi * speedFactor) + (i * 1.5);
      final px = center.dx + cos(angle) * r;
      final py = center.dy + sin(angle) * r;

      canvas.drawCircle(Offset(px, py), 4.0, beadGlowPaint);
      canvas.drawCircle(Offset(px, py), 2.0, goldBeadPaint);
    }

    // 2. Dark Vignette Overlay
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
  bool shouldRepaint(covariant _CalendarTimePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
