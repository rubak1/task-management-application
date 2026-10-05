import 'dart:math';
import 'package:flutter/material.dart';

class TrendDataPoint {
  final String label;
  final double amount;

  TrendDataPoint({required this.label, required this.amount});
}

class SpendingTrendWidget extends StatelessWidget {
  final List<TrendDataPoint> points;
  final String currencySymbol;
  final double height;

  const SpendingTrendWidget({
    super.key,
    required this.points,
    required this.currencySymbol,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No spending data in this period',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
          ),
        ),
      );
    }

    final maxVal = points.fold<double>(0.0, (m, p) => max(m, p.amount));

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
                final ratio = maxVal > 0 ? (p.amount / maxVal).clamp(0.05, 1.0) : 0.05;
                final isZero = p.amount == 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (p.amount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              p.amount >= 1000
                                  ? '${(p.amount / 1000).toStringAsFixed(1)}k'
                                  : p.amount.toStringAsFixed(0),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        FractionallySizedBox(
                          heightFactor: ratio,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isZero
                                    ? [
                                        Colors.white.withValues(alpha: 0.04),
                                        Colors.white.withValues(alpha: 0.02),
                                      ]
                                    : [
                                        const Color(0xFF6366F1),
                                        const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: points.map((p) {
              return Expanded(
                child: Text(
                  p.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
