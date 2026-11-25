import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PosRoundingStepSelector extends StatelessWidget {
  final int selectedStep;
  final ValueChanged<int> onStepChanged;

  const PosRoundingStepSelector({
    super.key,
    required this.selectedStep,
    required this.onStepChanged,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [100, 500, 1000];

    return Row(
      children: steps.map((s) {
        final isSelected = selectedStep == s;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onStepChanged(s);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDFA) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    'Rp${CurrencyFormatter.formatNumber(s)}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
