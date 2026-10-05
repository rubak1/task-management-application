import 'dart:math';
import 'package:flutter/material.dart';

class SceneNeuralWires extends StatefulWidget {
  final bool isActive;
  final bool reducedMotion;

  const SceneNeuralWires({
    super.key,
    required this.isActive,
    required this.reducedMotion,
  });

  @override
  State<SceneNeuralWires> createState() => _SceneNeuralWiresState();
}

class _SceneNeuralWiresState extends State<SceneNeuralWires> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1.5x - 2x faster duration per prompt requirements
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    if (widget.isActive && !widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SceneNeuralWires oldWidget) {
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
      return Container(color: const Color(0xFF070709));
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _NeuralWiresPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _NeuralWiresPainter extends CustomPainter {
  final double progress;

  _NeuralWiresPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep black canvas
    final bgPaint = Paint()..color = const Color(0xFF060608);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. High-speed white neural pathway lines with glowing warm gold tips
    final wirePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.28);

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.55);

    const int wireCount = 10;
    for (int i = 0; i < wireCount; i++) {
      final isLeft = i % 2 == 0;
      final startX = isLeft
          ? (i * 25.0)
          : size.width - (i * 25.0);
      final path = Path();
      path.moveTo(startX, 0);

      // Fast dynamic wave computation
      final waveOffset = progress * 2 * pi;
      double currX = startX;
      double currY = 0;
      final totalSteps = 24;
      final stepY = size.height / totalSteps;

      for (int step = 1; step <= totalSteps; step++) {
        final sway = sin(step * 0.4 + waveOffset * 1.8 + i) * 28.0;
        currX = startX + sway;
        currY = step * stepY;
        path.lineTo(currX, currY);
      }

      canvas.drawPath(path, wirePaint);
      canvas.drawPath(path, corePaint);

      // Warm gold/orange tip pulse
      final tipGlowPaint = Paint()
        ..color = const Color(0xFFFFB703).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(currX, currY), 5.0, tipGlowPaint);

      final tipCorePaint = Paint()..color = const Color(0xFFFFF3CC);
      canvas.drawCircle(Offset(currX, currY), 2.0, tipCorePaint);
    }

    // 3. Dark Vignette and Ambient Overlay for maximum readability
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.50),
          Colors.black.withValues(alpha: 0.92),
        ],
        stops: const [0.25, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _NeuralWiresPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
