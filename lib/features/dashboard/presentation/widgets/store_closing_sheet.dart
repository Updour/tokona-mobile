import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/backup/data/services/supabase_backup_service.dart';
import 'package:tokona/features/backup/domain/models/cloud_backup_model.dart';
import 'package:tokona/features/dashboard/presentation/widgets/store_closing_summary_card.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';

class StoreClosingSheet extends ConsumerStatefulWidget {
  const StoreClosingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const StoreClosingSheet(),
    );
  }

  @override
  ConsumerState<StoreClosingSheet> createState() => _StoreClosingSheetState();
}

class _StoreClosingSheetState extends ConsumerState<StoreClosingSheet> {
  bool _autoBackupEnabled = true;
  bool _isLoading = false;
  CloudBackupModel? _backupResult;

  Future<void> _handleCloseStoreAndBackup(String storeId, String storeName) async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      CloudBackupModel? result;
      if (_autoBackupEnabled) {
        result = await SupabaseBackupService.createCloudBackup(
          storeId: storeId,
          storeName: storeName,
        );
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _backupResult = result;
      });
      AppToast.showSuccess(
        context,
        _autoBackupEnabled
            ? 'Tutup Toko Selesai! Cadangan berhasil diunggah ke Supabase Cloud.'
            : 'Tutup Toko Selesai!',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.showError(context, 'Gagal mencadangkan ke cloud: $e');
    }
  }

  void _shareClosingReportWA(String storeName, double totalOmset, int totalTrx, double cashPaid, double nonCash, double totalProfit) {
    final nowStr = DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(DateTime.now());
    final msg =
        '📊 *REKAP PENUTUPAN TOKO - $storeName*\n'
        '⏰ Waktu: $nowStr\n\n'
        '💰 *Total Omset*: ${CurrencyFormatter.format(totalOmset)}\n'
        '🧾 *Total Transaksi*: $totalTrx nota\n'
        '💵 *Uang Tunai Kasir*: ${CurrencyFormatter.format(cashPaid)}\n'
        '💳 *Non-Tunai / Lainnya*: ${CurrencyFormatter.format(nonCash)}\n'
        '📈 *Estimasi Laba Kotor*: ${CurrencyFormatter.format(totalProfit)}\n\n'
        '☁️ *Cadangan Cloud*: ${_backupResult != null ? "Sukses tersimpan di Supabase (${_backupResult!.formattedSize})" : "Offline"}\n'
        '✅ Toko berhasil ditutup dengan aman.';

    WhatsAppService.sendReceipt(phone: '', message: msg);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final store = authState.currentStore;
    final storeName = store?.name ?? 'Tokona Store';
    final storeId = store?.id ?? '';
    final salesState = ref.watch(saleHistoryControllerProvider);

    final now = DateTime.now();
    final todaySales = salesState.sales.where((s) {
      if (s.isVoided) return false;
      return s.createdAt.year == now.year && s.createdAt.month == now.month && s.createdAt.day == now.day;
    }).toList();

    double totalOmset = 0;
    double cashPaid = 0;
    double nonCash = 0;
    double totalProfit = 0;
    for (final s in todaySales) {
      totalOmset += s.finalAmount;
      totalProfit += s.totalProfit;
      if (s.paymentMethod.toUpperCase() == 'CASH') {
        cashPaid += s.finalAmount;
      } else {
        nonCash += s.finalAmount;
      }
    }

    final dateFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Center(
            child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF0D9488)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store_mall_directory_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rekap & Tutup Toko', style: AppTypography.headingSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('$dateFormatted • $storeName', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StoreClosingSummaryCard(
                    omset: totalOmset,
                    trxCount: todaySales.length,
                    cash: cashPaid,
                    nonCash: nonCash,
                    profit: totalProfit,
                  ),
                  const SizedBox(height: 12),
                  StoreClosingCloudCard(
                    enabled: _autoBackupEnabled,
                    isLoading: _isLoading,
                    onChanged: (v) => setState(() => _autoBackupEnabled = v),
                  ),
                  if (_backupResult != null) ...[
                    const SizedBox(height: 12),
                    StoreClosingSuccessCard(backupResult: _backupResult),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_backupResult != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareClosingReportWA(storeName, totalOmset, todaySales.length, cashPaid, nonCash, totalProfit),
                    icon: const Icon(Icons.share_rounded, size: 16, color: Color(0xFF059669)),
                    label: const Text('Kirim Rekap WA', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _handleCloseStoreAndBackup(storeId, storeName),
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
              label: Text(
                _isLoading ? 'Mencadangkan ke Supabase...' : (_autoBackupEnabled ? 'Tutup Toko & Backup Cloud' : 'Tutup Toko Saja'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
          ),
        ),
      ),
    );
  }
}
