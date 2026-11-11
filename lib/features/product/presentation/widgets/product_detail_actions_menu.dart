import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ProductDetailActionsMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onAdjustStock;
  final VoidCallback? onStockCard;
  final VoidCallback? onRestock;
  final VoidCallback? onDelete;

  const ProductDetailActionsMenu({
    super.key,
    this.onEdit,
    this.onAdjustStock,
    this.onStockCard,
    this.onRestock,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opsi Produk',
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'adjust_stock':
            onAdjustStock?.call();
            break;
          case 'stock_card':
            onStockCard?.call();
            break;
          case 'restock':
            onRestock?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Text('Edit Produk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        if (onAdjustStock != null)
          const PopupMenuItem(
            value: 'adjust_stock',
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 18, color: Color(0xFFD97706)),
                SizedBox(width: 10),
                Text('Penyesuaian Stok (Opname)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                Text('Kartu Riwayat Stok', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                Text('Beli / Restok Stok', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        if (onDelete != null) ...[
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
      ],
    );
  }
}

