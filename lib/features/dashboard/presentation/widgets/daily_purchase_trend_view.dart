import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/dashboard/presentation/widgets/sales_chart_header.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/report/domain/models/report_filter_type.dart';

class DailyPurchaseTrendView extends StatefulWidget {
  final List<PurchaseModel> purchases;
  final ReportFilterType activeFilter;
  final ValueChanged<ReportFilterType> onFilterSelected;

  const DailyPurchaseTrendView({
    super.key,
    required this.purchases,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  State<DailyPurchaseTrendView> createState() => _DailyPurchaseTrendViewState();
}

class _DailyPurchaseTrendViewState extends State<DailyPurchaseTrendView> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  ChartMode _chartMode = ChartMode.line;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<PurchaseModel> _filterPurchases() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return widget.purchases.where((p) {
      if (p.status == 'cancelled') return false;
      final d = DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
      switch (widget.activeFilter) {
        case ReportFilterType.today:
          return d.isAtSameMomentAs(today);
        case ReportFilterType.yesterday:
          return d.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
        case ReportFilterType.last7Days:
          return d.isAfter(today.subtract(const Duration(days: 7))) && !d.isAfter(today);
        case ReportFilterType.thisMonth:
          return d.year == now.year && d.month == now.month;
        case ReportFilterType.lastMonth:
          final prevMonth = DateTime(now.year, now.month - 1, 1);
          return d.year == prevMonth.year && d.month == prevMonth.month;
        case ReportFilterType.thisYear:
          return d.year == now.year;
        case ReportFilterType.custom:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterPurchases();
    final totalSpend = filtered.fold<double>(0.0, (acc, p) => acc + p.grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(totalSpend),
        const SizedBox(height: 12),
        if (filtered.isEmpty || totalSpend <= 0)
          _buildEmptyState()
        else
          _buildContent(filtered, totalSpend),
      ],
    );
  }

  Widget _buildHeader(double totalSpend) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 17, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Tren Pembelian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 5),
                    _buildPulsingLiveBadge(),
                  ],
                ),
                Row(
                  children: [
                    Text(widget.activeFilter.label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                    const SizedBox(width: 4),
                    Text('• ${CurrencyFormatter.format(totalSpend)}', style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ],
        ),
        _buildThreeDotsMenu(),
      ],
    );
  }

  Widget _buildPulsingLiveBadge() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF3B82F6),
          boxShadow: [
            BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3 + 0.5 * _pulseController.value), blurRadius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeDotsMenu() {
    const filters = [
      ReportFilterType.today,
      ReportFilterType.last7Days,
      ReportFilterType.thisMonth,
      ReportFilterType.thisYear,
    ];

    return PopupMenuButton<ReportFilterType>(
      initialValue: widget.activeFilter,
      icon: const Icon(Icons.more_vert_rounded, size: 19, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      tooltip: 'Pilih Periode',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: widget.onFilterSelected,
      itemBuilder: (context) {
        return filters.map((f) {
          final isSelected = widget.activeFilter == f;
          return PopupMenuItem<ReportFilterType>(
            value: f,
            height: 38,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 15,
                  color: isSelected ? const Color(0xFF2563EB) : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF2563EB) : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 140,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 32, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          const Text('Belum ada pembelian pada periode ini', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildContent(List<PurchaseModel> list, double total) {
    final Map<String, double> supplierTotals = {};
    for (final p in list) {
      final name = (p.supplierName != null && p.supplierName!.trim().isNotEmpty) ? p.supplierName!.trim() : 'Supplier Lain';
      supplierTotals[name] = (supplierTotals[name] ?? 0) + p.grandTotal;
    }
    final sortedSuppliers = supplierTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${list.length} Faktur Selesai', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
              Text('Total Belanja: ${CurrencyFormatter.format(total)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...sortedSuppliers.take(4).map((entry) {
          final pct = total > 0 ? (entry.value / total) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(entry.key, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                    ),
                    Text(CurrencyFormatter.format(entry.value), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 3),
                LinearProgressIndicator(
                  value: pct.clamp(0.05, 1.0),
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  borderRadius: BorderRadius.circular(3),
                  minHeight: 5,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

