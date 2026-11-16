import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/models/device_procurement_history_item.dart';

class ProductDeviceHistorySheet extends StatelessWidget {
  final String productName;
  final String baseUnit;
  final List<DeviceProcurementHistoryItem> items;

  const ProductDeviceHistorySheet({
    super.key,
    required this.productName,
    required this.baseUnit,
    required this.items,
  });

  static Future<void> show(
    BuildContext context, {
    required String productName,
    required String baseUnit,
    required List<DeviceProcurementHistoryItem> items,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDeviceHistorySheet(
        productName: productName,
        baseUnit: baseUnit,
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final dateOnlyFormat = DateFormat('dd MMM yyyy', 'id_ID');

    final receivedItems = items.where((i) => i.isReceived).toList();
    final inTransitItems = items.where((i) => !i.isReceived).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
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
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded, size: 20, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Riwayat Belanja per Device', style: AppTypography.headingSmall.copyWith(fontSize: 15)),
                    Text(productName, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView(
                children: [
                  if (inTransitItems.isNotEmpty) ...[
                    _buildSectionHeader('Sedang OTW / Indent (${inTransitItems.length})', Icons.local_shipping_outlined, const Color(0xFFEA580C)),
                    const SizedBox(height: 8),
                    ...inTransitItems.map((item) => _buildItemTile(item, dateFormat, dateOnlyFormat)),
                    const SizedBox(height: 16),
                  ],
                  if (receivedItems.isNotEmpty) ...[
                    _buildSectionHeader('Sudah Diterima (${receivedItems.length})', Icons.check_circle_outline_rounded, const Color(0xFF0F766E)),
                    const SizedBox(height: 8),
                    ...receivedItems.map((item) => _buildItemTile(item, dateFormat, dateOnlyFormat)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _buildItemTile(DeviceProcurementHistoryItem item, DateFormat dateFormat, DateFormat dateOnlyFormat) {
    final isReceived = item.isReceived;
    final qtyStr = item.quantity % 1 == 0 ? item.quantity.toInt().toString() : item.quantity.toStringAsFixed(1);
    final badgeColor = isReceived ? const Color(0xFF059669) : (item.isShipping ? const Color(0xFF0284C7) : const Color(0xFF7C3AED));
    final badgeBg = isReceived ? const Color(0xFFECFDF5) : (item.isShipping ? const Color(0xFFE0F2FE) : const Color(0xFFF5F3FF));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                    child: Text('📱 ${item.deviceTag}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF4338CA))),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(item.statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
                  ),
                ],
              ),
              Text(
                '+$qtyStr $baseUnit',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Faktur: ${item.invoiceNumber}${item.supplierName != null ? ' • ${item.supplierName}' : ''}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.trackingNumber != null && item.trackingNumber!.isNotEmpty)
                Text(
                  'Resi: ${item.trackingNumber}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF0F766E), fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(isReceived ? Icons.event_available_outlined : Icons.schedule_outlined, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                isReceived ? 'Diterima: ${dateFormat.format(item.date)}' : 'Dipesan: ${dateFormat.format(item.date)}',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
              if (!isReceived && item.estimatedArrival != null) ...[
                const SizedBox(width: 8),
                Text(
                  '• Est. Tiba: ${dateOnlyFormat.format(item.estimatedArrival!)}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFFEA580C), fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('Belum Ada Riwayat Perangkat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Riwayat barang diterima dan OTW per device akan tercatat otomatis saat kulakan.', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
