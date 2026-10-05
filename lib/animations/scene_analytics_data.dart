import 'dart:math';
import 'package:flutter/material.dart';

class SceneAnalyticsData extends StatefulWidget {
  final bool isActive;
  final bool reducedMotion;

  const SceneAnalyticsData({
    super.key,
    required this.isActive,
    required this.reducedMotion,
  });

  @override
  State<SceneAnalyticsData> createState() => _SceneAnalyticsDataState();
}

class _SceneAnalyticsDataState extends State<SceneAnalyticsData> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.isActive && !widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SceneAnalyticsData oldWidget) {
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
      return Container(color: const Color(0xFF050608));
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _AnalyticsDataPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _AnalyticsDataPainter extends CustomPainter {
  final double progress;

  _AnalyticsDataPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep data black
    final bgPaint = Paint()..color = const Color(0xFF050608);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Subtle Coordinate Matrix Grid
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    const double gridSize = 45.0;
    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1.5, 1.5), gridPaint);
      }
    }

    // 3. Flowing Data Streams
    for (int i = 0; i < 7; i++) {
      final x = (i * (size.width / 6)) + 15;
      final speed = 1.0 + (i * 0.2);
      final y = ((progress * speed) % 1.0) * size.height;

      final packetPaint = Paint()
        ..color = (i % 2 == 0)
            ? const Color(0xFFFFD166).withValues(alpha: 0.40)
            : Colors.white.withValues(alpha: 0.35);

      canvas.drawLine(
        Offset(x, max(0, y - 40)),
        Offset(x, y),
        Paint()
          ..color = packetPaint.color
          ..strokeWidth = 1.2,
      );

      canvas.drawCircle(Offset(x, y), 2.0, packetPaint);
    }

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
  bool shouldRepaint(covariant _AnalyticsDataPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
