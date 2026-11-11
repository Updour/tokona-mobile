import 'dart:math' as math;
import 'package:flutter/material.dart';

class PieSliceData {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  const PieSliceData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

class SalesPieChartPainter extends CustomPainter {
  final List<PieSliceData> slices;
  final double animationProgress;
  final int? selectedIndex;

  SalesPieChartPainter({
    required this.slices,
    required this.animationProgress,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.58;

    double startAngle = -math.pi / 2;
    final totalSweep = 2 * math.pi * animationProgress;

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweepAngle = (slice.percentage / 100.0) * totalSweep;
      final isSelected = selectedIndex == i;

      final currentOuter = isSelected ? outerRadius + 4 : outerRadius;
      final currentInner = isSelected ? innerRadius - 2 : innerRadius;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      final path = Path();
      path.arcTo(
        Rect.fromCircle(center: center, radius: currentOuter),
        startAngle,
        sweepAngle,
        false,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: currentInner),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      path.close();

      canvas.drawPath(path, paint);

      // White slice separator gap
      if (slices.length > 1) {
        final separatorPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawPath(path, separatorPaint);
      }

      startAngle += sweepAngle;
    }

    // Draw inner circle core
    final innerCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius - 3, innerCorePaint);
  }

  @override
  bool shouldRepaint(covariant SalesPieChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.slices != slices;
  }
}

