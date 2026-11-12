import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ProductCardOptionsMenu extends StatelessWidget {
  final VoidCallback? onAdjustStock;
  final VoidCallback? onStockCard;
  final VoidCallback? onRestock;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const ProductCardOptionsMenu({
    super.key,
    this.onAdjustStock,
    this.onStockCard,
    this.onRestock,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu Produk',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      onSelected: (value) {
        switch (value) {
          case 'adjust_stock':
            onAdjustStock?.call();
            break;
          case 'stock_card':
            onStockCard?.call();
            break;
          case 'restock':
            onRestock?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onAdjustStock != null)
          const PopupMenuItem(
            value: 'adjust_stock',
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 18, color: Color(0xFFD97706)),
                SizedBox(width: 10),
                Text('Stok Opname', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        if (onStockCard != null)
          const PopupMenuItem(
            value: 'stock_card',
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded, size: 18, color: Color(0xFF4F46E5)),
                SizedBox(width: 10),
                Text('Riwayat Stok', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        if (onRestock != null)
          const PopupMenuItem(
            value: 'restock',
            child: Row(
              children: [
                Icon(Icons.add_shopping_cart_rounded, size: 18, color: Color(0xFF0284C7)),
                SizedBox(width: 10),
                Text('Tambah Stok', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Text('Edit Produk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 10),
              Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.error)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}
