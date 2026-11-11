import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/domain/models/device_stock_summary.dart';
import 'package:tokona/features/product/presentation/widgets/device_stock_monitoring_sheet.dart';

class ProductDeviceFilterBar extends StatelessWidget {
  final List<DeviceStockSummary> deviceSummaries;
  final String? selectedDevice;
  final ValueChanged<String?> onSelectDevice;

  const ProductDeviceFilterBar({
    super.key,
    required this.deviceSummaries,
    required this.selectedDevice,
    required this.onSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    if (deviceSummaries.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPill(
                  label: 'Semua Device',
                  isSelected: selectedDevice == null,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSelectDevice(null);
                  },
                ),
                ...deviceSummaries.map((summary) {
                  final isSelected = selectedDevice == summary.deviceName;
                  final stockShort = summary.totalStock >= 1000
                      ? '${(summary.totalStock / 1000).toStringAsFixed(1)}k'
                      : summary.totalStock.toStringAsFixed(0);
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _buildPill(
                      label: '${summary.deviceName} ($stockShort)',
                      isSelected: isSelected,
                      icon: summary.isUntagged ? Icons.inventory_2_outlined : Icons.phone_android_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onSelectDevice(summary.deviceName);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => DeviceStockMonitoringSheet.show(
              context,
              summaries: deviceSummaries,
              selectedDeviceTag: selectedDevice,
              onSelectDevice: onSelectDevice,
            ),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text(
                    'Monitor',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

