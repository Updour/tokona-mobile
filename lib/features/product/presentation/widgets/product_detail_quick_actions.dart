import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ProductDetailQuickActions extends StatelessWidget {
  final VoidCallback? onQuickAdjust;
  final VoidCallback? onEdit;

  const ProductDetailQuickActions({
    super.key,
    this.onQuickAdjust,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onQuickAdjust != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onQuickAdjust,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text(
                'Kelola Stok & Harga',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF3C7),
                foregroundColor: const Color(0xFFB45309),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFFDE68A)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (onQuickAdjust != null && onEdit != null) const SizedBox(width: 8),
        if (onEdit != null)
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text(
              'Edit Lengkap',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }
}
