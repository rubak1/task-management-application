import 'dart:math';
import 'package:flutter/material.dart';

class SceneProductivityFlow extends StatefulWidget {
  final bool isActive;
  final bool reducedMotion;

  const SceneProductivityFlow({
    super.key,
    required this.isActive,
    required this.reducedMotion,
  });

  @override
  State<SceneProductivityFlow> createState() => _SceneProductivityFlowState();
}

class _SceneProductivityFlowState extends State<SceneProductivityFlow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    if (widget.isActive && !widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SceneProductivityFlow oldWidget) {
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
      return Container(color: const Color(0xFF06070A));
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProductivityFlowPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ProductivityFlowPainter extends CustomPainter {
  final double progress;

  _ProductivityFlowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep dark slate background
    final bgPaint = Paint()..color = const Color(0xFF06070A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.15);

    final nodePaint = Paint()..color = Colors.white.withValues(alpha: 0.50);

    // Subtle horizontal ideas/progress stream waves
    for (int wave = 1; wave <= 4; wave++) {
      final path = Path();
      final yBase = size.height * (wave * 0.22);
      for (double x = 0; x <= size.width; x += 20) {
        final y = yBase +
            sin(x * 0.008 + progress * 2 * pi + wave) * 22.0 +
            cos(x * 0.012 - progress * pi) * 10.0;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        // Draw occasional node on flow stream
        if ((x.toInt() % 100) == 0) {
          canvas.drawCircle(Offset(x, y), 2.0, nodePaint);
        }
      }
      canvas.drawPath(path, linePaint);
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
  bool shouldRepaint(covariant _ProductivityFlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
