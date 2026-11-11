import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/pos/domain/models/sale_history_state.dart';

class SalesHistoryFilterSheet extends StatelessWidget {
  final SaleHistoryState state;
  final ValueChanged<SaleDateFilter> onDateFilterChanged;
  final VoidCallback onPickCustomDates;
  final ValueChanged<String> onPaymentMethodChanged;
  final VoidCallback onResetFilter;

  const SalesHistoryFilterSheet({
    super.key,
    required this.state,
    required this.onDateFilterChanged,
    required this.onPickCustomDates,
    required this.onPaymentMethodChanged,
    required this.onResetFilter,
  });

  static Future<void> show(
    BuildContext context, {
    required SaleHistoryState state,
    required ValueChanged<SaleDateFilter> onDateFilterChanged,
    required VoidCallback onPickCustomDates,
    required ValueChanged<String> onPaymentMethodChanged,
    required VoidCallback onResetFilter,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SalesHistoryFilterSheet(
        state: state,
        onDateFilterChanged: onDateFilterChanged,
        onPickCustomDates: onPickCustomDates,
        onPaymentMethodChanged: onPaymentMethodChanged,
        onResetFilter: onResetFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methods = [
      ('ALL', 'Semua Cara Bayar'),
      ('CASH', 'Tunai'),
      ('QRIS', 'QRIS'),
      ('TRANSFER', 'Transfer Bank'),
      ('KASBON', 'Kasbon / Hutang'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppColors.primaryDark, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Filter Riwayat Penjualan',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  onResetFilter();
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restart_alt_rounded, size: 13, color: Color(0xFFDC2626)),
                      SizedBox(width: 4),
                      Text('Reset', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          const Text('RENTANG WAKTU TRANSAKSI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.textMuted, letterSpacing: 0.4)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...SaleDateFilter.values.where((f) => f != SaleDateFilter.custom).map((f) {
                final isSelected = state.dateFilter == f;
                return ChoiceChip(
                  label: Text(f.label),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      onDateFilterChanged(f);
                      Navigator.of(context).pop();
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.date_range_rounded, size: 14),
                label: Text(
                  state.dateFilter == SaleDateFilter.custom && state.customStartDate != null
                      ? '${DateFormat('dd/MM').format(state.customStartDate!)} - ${DateFormat('dd/MM').format(state.customEndDate!)}'
                      : 'Pilih Tanggal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: state.dateFilter == SaleDateFilter.custom ? FontWeight.w800 : FontWeight.w600,
                    color: state.dateFilter == SaleDateFilter.custom ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                backgroundColor: state.dateFilter == SaleDateFilter.custom ? AppColors.primary : AppColors.surfaceElevated,
                onPressed: () {
                  Navigator.of(context).pop();
                  onPickCustomDates();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('METODE PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.textMuted, letterSpacing: 0.4)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: methods.map((m) {
              final isSelected = state.paymentMethodFilter == m.$1;
              return ChoiceChip(
                label: Text(m.$2),
                selected: isSelected,
                onSelected: (val) {
                  if (val) {
                    onPaymentMethodChanged(m.$1);
                    Navigator.of(context).pop();
                  }
                },
                selectedColor: const Color(0xFF0D9488),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Terapkan Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

