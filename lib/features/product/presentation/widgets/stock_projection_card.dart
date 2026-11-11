import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class StockProjectionCard extends StatelessWidget {
  final double currentStock;
  final double inputQty;
  final double calculatedStock;
  final String type;
  final String unit;

  const StockProjectionCard({
    super.key,
    required this.currentStock,
    required this.inputQty,
    required this.calculatedStock,
    required this.type,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem('Stok Awal', '${currentStock.toStringAsFixed(0)} $unit', AppColors.textPrimary),
          const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
          _buildItem(
            'Perubahan',
            '${type == "in" ? "+" : "-"}${inputQty.toStringAsFixed(0)} $unit',
            type == 'in' ? const Color(0xFF15803D) : AppColors.error,
          ),
          const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
          _buildItem(
            'Stok Akhir',
            '${calculatedStock.toStringAsFixed(0)} $unit',
            calculatedStock < 0 ? AppColors.error : AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor)),
      ],
    );
  }
}

