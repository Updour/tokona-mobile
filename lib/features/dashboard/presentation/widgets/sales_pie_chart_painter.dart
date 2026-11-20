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
    if (slices.isEmpty || animationProgress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.56;
    final strokeWidth = outerRadius - innerRadius;
    final midRadius = (outerRadius + innerRadius) / 2;

    double startAngle = -math.pi / 2;
    final totalSweep = 2 * math.pi * animationProgress.clamp(0.001, 1.0);

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final rawSweep = (slice.percentage / 100.0) * totalSweep;
      if (rawSweep <= 0) continue;

      // Hindari Skia modulo 2*pi bug (arcTo/drawArc 2*pi dianggap 0 radians)
      final sweepAngle = math.min(rawSweep, 2 * math.pi - 0.0002);
      final isSelected = selectedIndex == i;

      final currentStroke = isSelected ? strokeWidth + 4 : strokeWidth;
      final currentRadius = isSelected ? midRadius + 2 : midRadius;

      // Jarak halus antar-slice jika lebih dari 1 produk
      final gap = slices.length > 1 ? 0.045 : 0.0;
      final effectiveSweep = math.max(0.005, sweepAngle - gap);
      final sliceStart = startAngle + (gap / 2);

      final paint = Paint()
        ..color = isSelected ? slice.color : slice.color.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentStroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        sliceStart,
        effectiveSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Lingkaran tengah halus (soft donut hole)
    final holePaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius - 2, holePaint);

    final holeBorder = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, innerRadius - 2, holeBorder);
  }

  @override
  bool shouldRepaint(covariant SalesPieChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.slices != slices;
  }
}
