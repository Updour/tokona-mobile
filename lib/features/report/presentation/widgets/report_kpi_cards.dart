import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/report/domain/models/report_summary_model.dart';

class ReportKpiCards extends StatelessWidget {
  final ReportSummaryModel summary;

  const ReportKpiCards({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeroProfitCard(),
        const SizedBox(height: 10),
        _buildSeamlessMetricsGrid(),
        if (summary.totalPendingRefund > 0) ...[
          const SizedBox(height: 10),
          _buildPendingRefundNotice(),
        ],
      ],
    );
  }

  Widget _buildHeroProfitCard() {
    final isProfitable = summary.grossProfit >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0F172A), AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Omset Penjualan Bersih', style: AppTypography.bodySmall.copyWith(color: Colors.white70, fontSize: 12.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: (isProfitable ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isProfitable ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Margin ${summary.profitMargin.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isProfitable ? const Color(0xFF34D399) : const Color(0xFFFCA5A5),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            CurrencyFormatter.format(summary.totalRevenue),
            style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimasi Laba Kotor', style: TextStyle(color: Colors.white60, fontSize: 10.5)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(summary.grossProfit),
                      style: TextStyle(
                        color: isProfitable ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total HPP', style: TextStyle(color: Colors.white60, fontSize: 10.5)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(summary.totalCogs),
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeamlessMetricsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCell(
                  title: 'HPP Modal',
                  value: CurrencyFormatter.format(summary.totalCogs),
                  subtitle: 'Biaya pokok barang',
                  icon: Icons.inventory_2_outlined,
                  accentColor: const Color(0xFF64748B),
                  accentBg: const Color(0xFFF1F5F9),
                ),
              ),
              Container(width: 0.9, height: 74, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: _buildMetricCell(
                  title: 'Belanja Masuk',
                  value: CurrencyFormatter.format(summary.totalPurchaseSpend),
                  subtitle: 'Kulakan periode ini',
                  icon: Icons.shopping_bag_outlined,
                  accentColor: const Color(0xFF0284C7),
                  accentBg: const Color(0xFFE0F2FE),
                ),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 0.9, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              Expanded(
                child: _buildMetricCell(
                  title: 'Total Transaksi',
                  value: '${summary.transactionCount} Nota',
                  subtitle: 'Struk kasir dilayani',
                  icon: Icons.receipt_long_outlined,
                  accentColor: const Color(0xFF8B5CF6),
                  accentBg: const Color(0xFFF3E8FF),
                ),
              ),
              Container(width: 0.9, height: 74, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: _buildMetricCell(
                  title: 'Rata-rata Nota',
                  value: CurrencyFormatter.format(summary.averageBasket),
                  subtitle: 'Nilai per belanjaan',
                  icon: Icons.analytics_outlined,
                  accentColor: const Color(0xFF10B981),
                  accentBg: const Color(0xFFD1FAE5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCell({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color accentBg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5.5),
                decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(7)),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1.5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRefundNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dana Tertahan di Rekening', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF991B1B))),
                Text('${CurrencyFormatter.format(summary.totalPendingRefund)} menunggu penarikan', style: const TextStyle(fontSize: 10.5, color: Color(0xFFB91C1C))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
