import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/whatsapp_phone_input_dialog.dart';
import 'package:tokona/features/report/data/services/report_export_service.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class ReportExportBottomSheet extends ConsumerStatefulWidget {
  const ReportExportBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportExportBottomSheet(),
    );
  }

  @override
  ConsumerState<ReportExportBottomSheet> createState() => _ReportExportBottomSheetState();
}

class _ReportExportBottomSheetState extends ConsumerState<ReportExportBottomSheet> {
  bool _isExporting = false;
  String? _savedFilePath;

  Future<void> _handleExportCsv() async {
    setState(() => _isExporting = true);
    try {
      final store = ref.read(authProvider).currentStore;
      final reportState = ref.read(reportControllerProvider);
      final saleState = ref.read(saleHistoryControllerProvider);

      final csvContent = ReportExportService.generateCsv(
        storeName: store?.name ?? 'Tokona Store',
        report: reportState,
        sales: saleState.sales,
        storeAddress: store?.address,
        storePhone: store?.phone,
      );

      final file = await ReportExportService.saveCsvFile(
        csvContent: csvContent,
        prefix: 'Tokona_${store?.name?.replaceAll(RegExp(r'\s+'), '_') ?? "Laporan"}',
      );

      if (mounted) {
        setState(() {
          _isExporting = false;
          _savedFilePath = file.path;
        });
        HapticFeedback.mediumImpact();
        AppToast.showSuccess(context, 'File Excel (CSV) berhasil disimpan di perangkat');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        AppToast.showError(context, 'Gagal mengekspor file: $e');
      }
    }
  }

  Future<void> _handleSendWhatsApp() async {
    final store = ref.read(authProvider).currentStore;
    final reportState = ref.read(reportControllerProvider);
    final saleState = ref.read(saleHistoryControllerProvider);

    final summaryText = ReportExportService.generateSummaryText(
      storeName: store?.name ?? 'Tokona Store',
      report: reportState,
      sales: saleState.sales,
    );

    final storePhone = store?.phone;
    if (storePhone != null && storePhone.trim().isNotEmpty) {
      final ok = await ReportExportService.sendSummaryToWhatsApp(
        phone: storePhone,
        summaryMessage: summaryText,
      );
      if (!ok && mounted) {
        WhatsAppPhoneInputDialog.show(context, receiptText: summaryText);
      }
    } else {
      WhatsAppPhoneInputDialog.show(context, receiptText: summaryText);
    }
  }

  void _copySummaryText() {
    final store = ref.read(authProvider).currentStore;
    final reportState = ref.read(reportControllerProvider);
    final saleState = ref.read(saleHistoryControllerProvider);

    final text = ReportExportService.generateSummaryText(
      storeName: store?.name ?? 'Tokona Store',
      report: reportState,
      sales: saleState.sales,
    );
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    AppToast.showSuccess(context, 'Format teks laporan disalin ke clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_chart_rounded, color: Color(0xFF15803D), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ekspor Laporan Keuangan', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    Text(
                      'Periode: ${reportState.activeFilterLabel}',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const Divider(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol('Omset Bersih', currency.format(reportState.summary.totalRevenue), AppColors.primary),
                Container(width: 1, height: 32, color: AppColors.border),
                _buildMetricCol('Laba Kotor', currency.format(reportState.summary.grossProfit), const Color(0xFF059669)),
                Container(width: 1, height: 32, color: AppColors.border),
                _buildMetricCol('Transaksi', '${reportState.summary.transactionCount}', AppColors.textPrimary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_savedFilePath != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File tersimpan di:\n$_savedFilePath',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            onPressed: _isExporting ? null : _handleExportCsv,
            icon: _isExporting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.file_download_rounded, size: 18),
            label: Text(
              _isExporting ? 'Menyiapkan File...' : 'Download File Excel (.CSV)',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleSendWhatsApp,
                  icon: const Icon(Icons.send_rounded, size: 16, color: Color(0xFF047857)),
                  label: const Text('Kirim ke WA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF047857))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: const BorderSide(color: Color(0xFFA7F3D0)),
                    backgroundColor: const Color(0xFFECFDF5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copySummaryText,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Salin Ringkasan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

