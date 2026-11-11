import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/models/device_stock_summary.dart';

class DeviceStockMonitoringSheet extends StatelessWidget {
  final List<DeviceStockSummary> summaries;
  final String? selectedDeviceTag;
  final ValueChanged<String?> onSelectDevice;

  const DeviceStockMonitoringSheet({
    super.key,
    required this.summaries,
    required this.selectedDeviceTag,
    required this.onSelectDevice,
  });

  static Future<void> show(
    BuildContext context, {
    required List<DeviceStockSummary> summaries,
    required String? selectedDeviceTag,
    required ValueChanged<String?> onSelectDevice,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeviceStockMonitoringSheet(
        summaries: summaries,
        selectedDeviceTag: selectedDeviceTag,
        onSelectDevice: onSelectDevice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAllStock = summaries.fold<double>(0, (sum, s) => sum + s.totalStock);
    final totalAllSku = summaries.fold<int>(0, (sum, s) => sum + s.totalProducts);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.devices_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monitoring Stok per Device', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      'Total $totalAllSku produk • ${totalAllStock.toStringAsFixed(0)} pcs sisa stok fisik',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              if (selectedDeviceTag != null)
                TextButton(
                  onPressed: () {
                    onSelectDevice(null);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset Filter', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (summaries.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_android_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text('Belum ada data device untuk produk', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: summaries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = summaries[index];
                  final isSelected = selectedDeviceTag == item.deviceName;
                  return _buildDeviceCard(context, item, isSelected);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, DeviceStockSummary item, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.isUntagged ? Icons.inventory_2_outlined : Icons.phone_android_rounded,
                  size: 16,
                  color: isSelected ? Colors.white : const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${item.totalProducts} varian produk terdaftar',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  onSelectDevice(isSelected ? null : item.deviceName);
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.filter_alt_outlined,
                        size: 13,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSelected ? 'Aktif' : 'Filter',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.layers_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    const Text('Sisa Stok Fisik:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    Text(
                      '${item.totalStock.toStringAsFixed(0)} pcs',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                if (item.lowStockCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.lowStockCount} menipis',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                    ),
                  )
                else
                  const Text('Stok Aman', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

