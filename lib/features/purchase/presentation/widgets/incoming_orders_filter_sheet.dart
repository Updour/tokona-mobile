import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class IncomingOrdersFilterSheet extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onSelectFilter;

  const IncomingOrdersFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onSelectFilter,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentFilter,
    required ValueChanged<String> onSelectFilter,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IncomingOrdersFilterSheet(
        currentFilter: currentFilter,
        onSelectFilter: onSelectFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
              Text('Filter Status Pesanan', style: AppTypography.headingSmall.copyWith(fontSize: 15)),
              const SizedBox(height: 10),
              _buildOption(context, 'Semua Pesanan Aktif', 'ALL'),
              _buildOption(context, 'Pre-Order (PO) Saja', 'PO'),
              _buildOption(context, 'Dalam Pengiriman Saja', 'SHIPPING'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label, String value) {
    final isSelected = currentFilter == value;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20) : null,
      onTap: () {
        onSelectFilter(value);
        Navigator.of(context).pop();
      },
    );
  }
}

