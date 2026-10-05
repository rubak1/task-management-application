import 'dart:math';
import 'package:flutter/material.dart';

class DonutChartData {
  final String label;
  final double value;
  final Color color;

  DonutChartData({required this.label, required this.value, required this.color});
}

class DonutChartWidget extends StatelessWidget {
  final List<DonutChartData> data;
  final String centerTitle;
  final String centerSubtitle;
  final double size;

  const DonutChartWidget({
    super.key,
    required this.data,
    required this.centerTitle,
    required this.centerSubtitle,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            'No expense data yet',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _DonutChartPainter(data: data),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    centerTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutChartData> data;

  _DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 18.0;

    final total = data.fold<double>(0.0, (acc, item) => acc + item.value);
    if (total == 0) return;

    var startAngle = -pi / 2;

    for (final item in data) {
      final sweepAngle = (item.value / total) * 2 * pi;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Small gap between slices
      final adjustedSweep = sweepAngle > 0.08 ? sweepAngle - 0.04 : sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + 0.02,
        adjustedSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
