import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tokona/features/report/domain/models/daily_trend_point.dart';

class SalesTrendChartPainter extends CustomPainter {
  final List<DailyTrendPoint> points;
  final double animationProgress;
  final double pulseProgress;
  final int? selectedIndex;
  final bool isBarChart;
  final Color primaryColor;
  final Color secondaryColor;

  SalesTrendChartPainter({
    required this.points,
    required this.animationProgress,
    required this.pulseProgress,
    this.selectedIndex,
    this.isBarChart = false,
    this.primaryColor = const Color(0xFF0D9488),
    this.secondaryColor = const Color(0xFF14B8A6),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final bottomPadding = 22.0;
    final topPadding = 16.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width;

    final double maxRevenue = points.map((p) => p.revenue).fold(0.0, math.max);
    final double safeMax = maxRevenue > 0 ? maxRevenue * 1.15 : 100.0;

    _drawGridLines(canvas, size, topPadding, chartHeight);

    if (isBarChart) {
      _drawBars(canvas, size, topPadding, chartHeight, safeMax);
      return;
    }

    if (points.length == 1) {
      final x = size.width / 2;
      final y = topPadding + chartHeight * 0.5;
      _drawPulsingNode(canvas, Offset(x, y));
      return;
    }

    final double stepX = chartWidth / (points.length - 1);
    final List<Offset> offsets = [];

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final normalizedY = (points[i].revenue / safeMax).clamp(0.0, 1.0);
      final animatedY = normalizedY * animationProgress;
      final y = topPadding + chartHeight * (1.0 - animatedY);
      offsets.add(Offset(x, y));
    }

    _drawAreaGradient(canvas, offsets, topPadding + chartHeight);
    _drawCurvedLine(canvas, offsets);
    _drawDataNodes(canvas, offsets);
  }

  void _drawGridLines(Canvas canvas, Size size, double top, double height) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 2; i++) {
      final y = top + (height * (i / 2));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawBars(Canvas canvas, Size size, double top, double chartHeight, double safeMax) {
    final count = points.length;
    final double slotWidth = size.width / count;
    final double barWidth = math.min(22.0, slotWidth * 0.55);

    for (int i = 0; i < count; i++) {
      final isSelected = selectedIndex == i;
      final isLatest = i == count - 1;
      final p = points[i];
      final normalizedY = (p.revenue / safeMax).clamp(0.05, 1.0);
      final h = chartHeight * normalizedY * animationProgress;
      final cx = (i * slotWidth) + (slotWidth / 2);
      final left = cx - (barWidth / 2);
      final barTop = top + chartHeight - h;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, barTop, barWidth, h),
        const Radius.circular(6),
      );

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
              : (isLatest
                  ? [primaryColor, secondaryColor]
                  : [const Color(0xFF6366F1), const Color(0xFF4F46E5)]),
        ).createShader(rect.outerRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, barPaint);

      if (isLatest || isSelected) {
        final glowAlpha = (1.0 - pulseProgress).clamp(0.0, 0.7) * 0.4;
        final glowPaint = Paint()
          ..color = primaryColor.withValues(alpha: glowAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawRRect(rect.inflate(2.0 + (pulseProgress * 3.0)), glowPaint);
      }
    }
  }

  void _drawAreaGradient(Canvas canvas, List<Offset> offsets, double bottomY) {
    if (offsets.length < 2) return;
    final path = Path();
    path.moveTo(offsets.first.dx, bottomY);
    path.lineTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    path.lineTo(offsets.last.dx, bottomY);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.32 * animationProgress),
          secondaryColor.withValues(alpha: 0.08 * animationProgress),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, offsets.last.dx, bottomY))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  void _drawCurvedLine(Canvas canvas, List<Offset> offsets) {
    if (offsets.length < 2) return;
    final path = Path();
    path.moveTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  void _drawDataNodes(Canvas canvas, List<Offset> offsets) {
    for (int i = 0; i < offsets.length; i++) {
      final isSelected = selectedIndex == i;
      final isLatest = i == offsets.length - 1;
      final offset = offsets[i];

      if (isSelected) {
        final guidePaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.35)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(offset.dx, 10), Offset(offset.dx, offset.dy + 30), guidePaint);
      }

      if (isLatest || isSelected) {
        _drawPulsingNode(canvas, offset);
      } else {
        final outerPaint = Paint()..color = primaryColor..style = PaintingStyle.fill;
        canvas.drawCircle(offset, 3.5, outerPaint);
        final innerPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
        canvas.drawCircle(offset, 1.8, innerPaint);
      }
    }
  }

  void _drawPulsingNode(Canvas canvas, Offset offset) {
    final pulseRadius = 5.0 + (pulseProgress * 8.0);
    final pulseAlpha = (1.0 - pulseProgress).clamp(0.0, 0.8) * 0.45;

    final haloPaint = Paint()..color = primaryColor.withValues(alpha: pulseAlpha)..style = PaintingStyle.fill;
    canvas.drawCircle(offset, pulseRadius, haloPaint);

    final midRingPaint = Paint()..color = secondaryColor.withValues(alpha: 0.25)..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 7.0, midRingPaint);

    final outerPaint = Paint()..color = primaryColor..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 4.5, outerPaint);

    final innerPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 2.2, innerPaint);
  }

  @override
  bool shouldRepaint(covariant SalesTrendChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isBarChart != isBarChart ||
        oldDelegate.points != points;
  }
}
