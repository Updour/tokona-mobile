import 'package:flutter/material.dart';

class PosReceiptPaperCard extends StatelessWidget {
  final String thermalText;

  const PosReceiptPaperCard({
    super.key,
    required this.thermalText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              18,
              (i) => Container(
                width: 8,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            thermalText,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.5,
              height: 1.38,
              color: Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              18,
              (i) => Container(
                width: 8,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
