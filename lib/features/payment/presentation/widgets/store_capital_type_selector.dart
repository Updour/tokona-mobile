import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class StoreCapitalTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const StoreCapitalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      ('TAMBAH_MODAL', 'Tambah Modal', const Color(0xFF0D9488)),
      ('MODAL_AWAL', 'Modal Awal', const Color(0xFF2563EB)),
      ('TARIK_MODAL', 'Tarik Modal (Prive)', AppColors.error),
    ];

    return Row(
      children: types.map((t) {
        final isSelected = selectedType == t.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ChoiceChip(
              label: Text(t.$2),
              selected: isSelected,
              onSelected: (val) {
                if (val) onTypeSelected(t.$1);
              },
              selectedColor: t.$3,
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 2),
            ),
          ),
        );
      }).toList(),
    );
  }
}
