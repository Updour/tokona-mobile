import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;
  final double cornerLength;
  final double cornerWidth;

  const ScannerOverlayPainter({
    required this.scanWindow,
    this.borderRadius = 16.0,
    this.cornerLength = 28.0,
    this.cornerWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final windowRRect = RRect.fromRectAndRadius(
      scanWindow,
      Radius.circular(borderRadius),
    );
    final windowPath = Path()..addRRect(windowRRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      windowPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(windowRRect, borderPaint);

    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final left = scanWindow.left;
    final top = scanWindow.top;
    final right = scanWindow.right;
    final bottom = scanWindow.bottom;
    final r = borderRadius;

    // Top-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + r)
        ..arcToPoint(Offset(left + r, top), radius: Radius.circular(r))
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );

    // Top-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, top)
        ..lineTo(right - r, top)
        ..arcToPoint(Offset(right, top + r), radius: Radius.circular(r))
        ..lineTo(right, top + cornerLength),
      cornerPaint,
    );

    // Bottom-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerLength)
        ..lineTo(left, bottom - r)
        ..arcToPoint(Offset(left + r, bottom), radius: Radius.circular(r))
        ..lineTo(left + cornerLength, bottom),
      cornerPaint,
    );

    // Bottom-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, bottom)
        ..lineTo(right - r, bottom)
        ..arcToPoint(Offset(right, bottom - r), radius: Radius.circular(r))
        ..lineTo(right, bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}
