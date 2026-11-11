import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/product/domain/models/in_transit_device_item.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';

class ProductDetailInventoryInfoCard extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailInventoryInfoCard({super.key, required this.product});

  @override
  ConsumerState<ProductDetailInventoryInfoCard> createState() => _ProductDetailInventoryInfoCardState();
}

class _ProductDetailInventoryInfoCardState extends ConsumerState<ProductDetailInventoryInfoCard> {
  Map<String, double> _deviceBreakdown = {};

  @override
  void initState() {
    super.initState();
    _loadDeviceBreakdown();
  }

  Future<void> _loadDeviceBreakdown() async {
    try {
      final data = await ref.read(purchaseRepositoryProvider).getProductDeviceBreakdown(widget.product.id);
      if (mounted) setState(() => _deviceBreakdown = data);
    } catch (_) {}
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    AppToast.showSuccess(context, '$label berhasil disalin');
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final dateOnlyFormat = DateFormat('dd MMMM yyyy');
    final product = widget.product;
    final activeOrders = ref.watch(activeOrdersProvider);
    final inTransitList = InTransitDeviceItem.fromActiveOrders(activeOrders, product.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 8),
              Text('Informasi Inventaris & Sistem', style: AppTypography.labelMedium.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          _buildRow(
            icon: Icons.inventory_2_outlined,
            label: 'Stok Fisik Tersedia',
            value: '${product.stockBase.toStringAsFixed(0)} ${product.baseUnit}',
            badge: _buildStockStatusBadge(),
          ),
          const Divider(height: 16),
          _buildRow(
            icon: Icons.warning_amber_rounded,
            label: 'Batas Peringatan Minimum',
            value: '${product.minStockAlert.toStringAsFixed(0)} ${product.baseUnit}',
          ),
          const Divider(height: 16),
          _buildRow(
            icon: Icons.qr_code_2_rounded,
            label: 'Barcode / SKU',
            value: product.sku != null && product.sku!.isNotEmpty ? product.sku! : 'Tanpa SKU',
            trailing: product.sku != null && product.sku!.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 15, color: AppColors.primary),
                    tooltip: 'Salin SKU',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copyToClipboard(context, product.sku!, 'SKU'),
                  )
                : null,
          ),
          const Divider(height: 16),
          _buildRow(
            icon: Icons.category_outlined,
            label: 'Kategori Produk',
            value: product.category ?? 'Tanpa Kategori',
          ),
          const Divider(height: 16),
          _buildRow(
            icon: Icons.widgets_outlined,
            label: 'Tipe Produk',
            value: product.productType,
          ),
          if (product.deviceTags.isNotEmpty || _deviceBreakdown.isNotEmpty || inTransitList.isNotEmpty) ...[
            const Divider(height: 16),
            _buildRow(
              icon: Icons.phone_android_rounded,
              label: 'Device Terdaftar',
              value: [
                ...product.deviceTags,
                ...inTransitList.map((i) => '${i.deviceTag} (${i.statusLabel})'),
              ].join(', '),
            ),
            if (_deviceBreakdown.isNotEmpty || inTransitList.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDeviceBreakdownCard(_deviceBreakdown, inTransitList),
            ],
          ],
          if (product.expiredAt != null) ...[
            const Divider(height: 16),
            _buildRow(
              icon: Icons.event_outlined,
              label: 'Tanggal Kadaluwarsa',
              value: dateOnlyFormat.format(product.expiredAt!),
              badge: _buildExpiredBadge(),
            ),
          ],
          const Divider(height: 16),
          _buildRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal Ditambahkan',
            value: dateFormat.format(product.createdAt),
          ),
          const Divider(height: 16),
          _buildRow(
            icon: Icons.update_rounded,
            label: 'Terakhir Diperbarui',
            value: dateFormat.format(product.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceBreakdownCard(Map<String, double> breakdown, List<InTransitDeviceItem> inTransitList) {
    final entries = breakdown.entries.toList();
    final physicalQty = entries.fold<double>(0.0, (acc, e) => acc + e.value);
    final inTransitQty = inTransitList.fold<double>(0.0, (acc, i) => acc + i.quantity);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rincian Stok per Device:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Text('Fisik: ${physicalQty.toInt()} • OTW: ${inTransitQty.toInt()}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: [
              ...entries.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: Text('${e.key}: ${e.value.toInt()} ${widget.product.baseUnit}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              )),
              ...inTransitList.map((i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFF59E0B))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_shipping_rounded, size: 10, color: Color(0xFFD97706)),
                    const SizedBox(width: 3),
                    Text('${i.deviceTag}: ${i.quantity.toInt()} ${widget.product.baseUnit} (${i.statusLabel})', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? badge,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        if (badge != null) ...[
          badge,
          const SizedBox(width: 8),
        ],
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildStockStatusBadge() {
    final stock = widget.product.stockBase;
    if (stock <= 0) {
      return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(6)), child: const Text('Habis', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error)));
    }
    if (widget.product.isLowStock) {
      return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)), child: const Text('Menipis', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309))));
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.successContainer, borderRadius: BorderRadius.circular(6)), child: const Text('Aman', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success)));
  }

  Widget _buildExpiredBadge() {
    if (widget.product.isExpired) {
      return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(6)), child: const Text('Expired', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error)));
    }
    if (widget.product.isExpiringSoon) {
      return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)), child: const Text('Segera Exp', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309))));
    }
    return const SizedBox.shrink();
  }
}
