import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/domain/models/in_transit_device_item.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';

class StockBreakdownSheet extends StatelessWidget {
  final ProductModel product;
  final double totalPending;
  final List<InTransitDeviceItem> items;

  const StockBreakdownSheet({
    super.key,
    required this.product,
    required this.totalPending,
    required this.items,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductModel product,
    required double totalPending,
    required List<InTransitDeviceItem> items,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockBreakdownSheet(
        product: product,
        totalPending: totalPending,
        items: items,
      ),
    );
  }

  String _formatQty(double qty) {
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final physicalQty = product.stockBase;
    final totalProjected = physicalQty + totalPending;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: totalPending > 0 ? const Color(0xFFFEF3C7) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    totalPending > 0 ? Icons.pending_actions_rounded : Icons.inventory_2_outlined,
                    size: 20,
                    color: totalPending > 0 ? const Color(0xFFD97706) : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Rincian Stok Fisik & Pending di Perangkat',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  _buildRow(
                    label: 'Stok Fisik (Toko)',
                    value: '${_formatQty(physicalQty)} ${product.baseUnit}',
                    color: physicalQty <= 0 ? AppColors.error : AppColors.success,
                    isBold: true,
                  ),
                  const Divider(height: 14),
                  _buildRow(
                    label: 'Pending di Perangkat (PO/OTW)',
                    value: '+${_formatQty(totalPending)} ${product.baseUnit}',
                    color: totalPending > 0 ? const Color(0xFFD97706) : AppColors.textMuted,
                    isBold: totalPending > 0,
                  ),
                  const Divider(height: 14),
                  _buildRow(
                    label: 'Estimasi Total Jika Diterima',
                    value: '${_formatQty(totalProjected)} ${product.baseUnit}',
                    color: const Color(0xFF0F766E),
                    isBold: true,
                  ),
                ],
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Rincian Perangkat & Pesanan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => _buildItemTile(item)),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stok akan otomatis masuk ke stok fisik saat barang pesanan masuk diterima.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(InTransitDeviceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_android_rounded, size: 14, color: Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.deviceTag,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: item.isShipping
                  ? const Color(0xFFE0F2FE)
                  : (item.isPreOrder ? const Color(0xFFF3E8FF) : const Color(0xFFFEF3C7)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.isShipping ? 'Dikirim (Resi)' : (item.isPreOrder ? 'PO' : 'Belanja'),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: item.isShipping
                    ? const Color(0xFF0284C7)
                    : (item.isPreOrder ? const Color(0xFF7C3AED) : const Color(0xFFB45309)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${_formatQty(item.quantity)} ${product.baseUnit}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F766E)),
          ),
        ],
      ),
    );
  }
}
