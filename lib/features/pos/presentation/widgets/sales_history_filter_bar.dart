import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/pos/domain/models/sale_history_state.dart';

class SalesHistoryFilterBar extends StatelessWidget {
  final SaleHistoryState state;
  final ValueChanged<SaleDateFilter> onDateFilterChanged;
  final VoidCallback onPickCustomDates;
  final ValueChanged<String> onPaymentMethodChanged;

  const SalesHistoryFilterBar({
    super.key,
    required this.state,
    required this.onDateFilterChanged,
    required this.onPickCustomDates,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      ('ALL', 'Semua Cara Bayar'),
      ('CASH', 'Tunai'),
      ('QRIS', 'QRIS'),
      ('TRANSFER', 'Transfer'),
      ('KASBON', 'Kasbon / Hutang'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...SaleDateFilter.values.where((f) => f != SaleDateFilter.custom).map((f) {
                final isSelected = state.dateFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(f.label),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) onDateFilterChanged(f);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                    fontWeight: state.dateFilter == SaleDateFilter.custom ? FontWeight.w700 : FontWeight.w500,
                    color: state.dateFilter == SaleDateFilter.custom ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                backgroundColor: state.dateFilter == SaleDateFilter.custom ? AppColors.primary : AppColors.surfaceElevated,
                onPressed: onPickCustomDates,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: methods.map((m) {
              final isSelected = state.paymentMethodFilter == m.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(m.$2),
                  selected: isSelected,
                  onSelected: (_) => onPaymentMethodChanged(m.$1),
                  selectedColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  checkmarkColor: const Color(0xFF0D9488),
                  labelStyle: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF0D9488) : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

