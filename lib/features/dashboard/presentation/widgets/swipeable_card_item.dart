import 'package:flutter/material.dart';

class SwipeableCardItem extends StatelessWidget {
  final List<Color> gradient;
  final List<double> sparklineData;
  final IconData icon;
  final String badgeText;
  final Color badgeBg;
  final bool hasLiveDot;
  final String title;
  final String mainValue;
  final String footerLeftLabel;
  final String footerLeftValue;
  final String footerRightLabel;
  final String footerRightValue;
  final VoidCallback onTap;
  final VoidCallback? onBadgeTap;

  const SwipeableCardItem({
    super.key,
    required this.gradient,
    required this.sparklineData,
    required this.icon,
    required this.badgeText,
    required this.badgeBg,
    this.hasLiveDot = false,
    required this.title,
    required this.mainValue,
    required this.footerLeftLabel,
    required this.footerLeftValue,
    required this.footerRightLabel,
    required this.footerRightValue,
    required this.onTap,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: gradient.first.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CardBgPainter(data: sparklineData, color: Colors.white),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: onBadgeTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasLiveDot) ...[
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                                  const SizedBox(width: 4),
                                ],
                                Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                                if (onBadgeTap != null) ...[
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down_rounded, size: 14, color: Colors.white),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Icon(icon, color: Colors.white.withValues(alpha: 0.88), size: 22),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 11, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation),
                                child: child,
                              ),
                            ),
                            child: Text(
                              mainValue,
                              key: ValueKey<String>(mainValue),
                              style: const TextStyle(color: Colors.white, fontSize: 20.5, fontWeight: FontWeight.w900, letterSpacing: -0.4),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(9)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('$footerLeftLabel: ', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10)),
                                Flexible(
                                  child: Text(
                                    footerLeftValue,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (footerRightLabel.isNotEmpty)
                                Text('$footerRightLabel: ', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10)),
                              Text(footerRightValue, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBgPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _CardBgPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - minVal) / range;
      final y = size.height - (normalizedY * (size.height * 0.42)) - 4;
      final x = i * stepX;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (((data[i - 1] - minVal) / range) * (size.height * 0.42)) - 4;
        final midX = prevX + (x - prevX) / 2;
        path.cubicTo(midX, prevY, midX, y, x, y);
        fillPath.cubicTo(midX, prevY, midX, y, x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _CardBgPainter oldDelegate) => oldDelegate.data != data;
}

