import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/backup/domain/models/cloud_backup_model.dart';

class StoreClosingSummaryCard extends StatelessWidget {
  final double omset;
  final int trxCount;
  final double cash;
  final double nonCash;
  final double profit;

  const StoreClosingSummaryCard({
    super.key,
    required this.omset,
    required this.trxCount,
    required this.cash,
    required this.nonCash,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ringkasan Kasir Hari Ini', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                child: Text('$trxCount Transaksi', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(CurrencyFormatter.format(omset), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F766E))),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildDetailRow('💵 Uang Tunai di Laci Kasir', CurrencyFormatter.format(cash)),
          const SizedBox(height: 4),
          _buildDetailRow('💳 Non-Tunai / Transfer / QRIS', CurrencyFormatter.format(nonCash)),
          const SizedBox(height: 4),
          _buildDetailRow('📈 Estimasi Laba Kotor', CurrencyFormatter.format(profit), color: const Color(0xFF059669)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}

class StoreClosingCloudCard extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final ValueChanged<bool>? onChanged;

  const StoreClosingCloudCard({
    super.key,
    required this.enabled,
    required this.isLoading,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_sync_rounded, color: Color(0xFF16A34A), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Backup Cloud Supabase', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF166534))),
                    Text('db.gjgfdwzqjypzalzleqgt.supabase.co', style: TextStyle(fontSize: 10, color: Color(0xFF15803D))),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: isLoading ? null : (v) => onChanged?.call(v),
                activeColor: const Color(0xFF16A34A),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Saat toko ditutup, seluruh katalog produk, mutasi stok, transaksi, & pelanggan otomatis di-upload ke database cloud Supabase.',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF166534), height: 1.3),
          ),
        ],
      ),
    );
  }
}

class StoreClosingSuccessCard extends StatelessWidget {
  final CloudBackupModel? backupResult;

  const StoreClosingSuccessCard({super.key, required this.backupResult});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cadangan Cloud Berhasil!', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                Text(
                  '${backupResult?.totalRecords ?? 0} data • ${backupResult?.formattedSize ?? ""} tersimpan aman di Supabase',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF047857)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

