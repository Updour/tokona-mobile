import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class StockReasonSelector extends StatelessWidget {
  final String selectedReason;
  final String type;
  final ValueChanged<String> onReasonChanged;

  const StockReasonSelector({
    super.key,
    required this.selectedReason,
    required this.type,
    required this.onReasonChanged,
  });

  static const List<Map<String, String>> outReasons = [
    {'key': 'damaged', 'label': 'Rusak / Pecah'},
    {'key': 'expired', 'label': 'Kadaluarsa'},
    {'key': 'lost', 'label': 'Hilang / Selisih'},
    {'key': 'internal_use', 'label': 'Dipakai Toko'},
    {'key': 'opname_out', 'label': 'Koreksi Opname (-)'},
  ];

  static const List<Map<String, String>> inReasons = [
    {'key': 'opname_in', 'label': 'Temuan Fisik (+)'},
    {'key': 'manual', 'label': 'Koreksi Masuk'},
  ];

  @override
  Widget build(BuildContext context) {
    final reasons = type == 'out' ? outReasons : inReasons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Alasan Penyesuaian:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reasons.map((r) {
            final isSelected = selectedReason == r['key'];
            return ChoiceChip(
              label: Text(r['label']!),
              selected: isSelected,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              selectedColor: type == 'out' ? AppColors.error : AppColors.primary,
              backgroundColor: AppColors.surfaceInput,
              side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: (_) => onReasonChanged(r['key']!),
            );
          }).toList(),
        ),
      ],
    );
  }
}

