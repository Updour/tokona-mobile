import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_receipt_dialog.dart';
import 'package:tokona/features/pos/presentation/widgets/sale_detail_item_tile.dart';

class SaleDetailSheet extends ConsumerWidget {
  final SaleModel sale;

  const SaleDetailSheet({super.key, required this.sale});

  static Future<void> show(BuildContext context, SaleModel sale) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaleDetailSheet(sale: sale),
    );
  }

  Future<void> _handleVoidSale(BuildContext context, WidgetRef ref) async {
    final confirm = await AppDialog.showConfirmation(
      context,
      title: 'Batalkan Transaksi (Void)',
      message: 'Yakin ingin membatalkan nota ${sale.invoiceNumber}? Seluruh barang yang terjual akan otomatis dikembalikan ke stok toko.',
      confirmText: 'Ya, Batalkan Nota',
      isDestructive: true,
      icon: Icons.cancel_outlined,
    );

    if (confirm == true && context.mounted) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId == null) return;
      final ok = await ref.read(saleHistoryControllerProvider.notifier).voidSale(sale.id, storeId);
      if (ok && context.mounted) {
        AppToast.showSuccess(context, 'Transaksi berhasil dibatalkan');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final isVoid = sale.isVoided;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail Nota Penjualan', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(sale.invoiceNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 14),
                  _buildMetaSection(dateFormat),
                  const SizedBox(height: 16),
                  Text('Rincian Barang (${sale.items.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 6),
                  ...sale.items.map((it) => SaleDetailItemTile(item: it)),
                  const SizedBox(height: 14),
                  _buildPaymentSummary(),
                  _buildProofPhoto(context),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildBottomButtons(context, ref, isVoid),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (sale.isVoided) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
        child: const Row(children: [
          Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Nota transaksi ini telah DIBATALKAN. Stok telah dikembalikan ke inventaris.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.successContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
      child: Row(children: [
        const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text('Transaksi Selesai & Lunas (${sale.paymentMethod})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success))),
        if (sale.totalProfit > 0)
          Text('Laba +${CurrencyFormatter.format(sale.totalProfit)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.success)),
      ]),
    );
  }

  Widget _buildProofPhoto(BuildContext context) {
    if (sale.imagePath == null || sale.imagePath!.trim().isEmpty) return const SizedBox.shrink();
    final file = File(sale.imagePath!);
    if (!file.existsSync()) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.photo_camera_back_outlined, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Foto Bukti Pembayaran / Nota', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => Dialog(
                backgroundColor: Colors.transparent,
                child: InteractiveViewer(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file))),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(file, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Ketuk foto untuk melihat layar penuh (zoom)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildMetaSection(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildMetaRow('Waktu Transaksi', dateFormat.format(sale.createdAt)),
          const SizedBox(height: 8),
          _buildMetaRow('Pelanggan', sale.customerName ?? 'Pelanggan Umum'),
          const SizedBox(height: 8),
          _buildMetaRow('Metode Pembayaran', sale.paymentMethod),
          if (sale.notes != null && sale.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildMetaRow('Catatan', sale.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildMetaRow('Subtotal Belanja', CurrencyFormatter.format(sale.totalAmount)),
          if (sale.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diskon Transaksi', style: TextStyle(fontSize: 11.5, color: AppColors.error)),
                Text('-${CurrencyFormatter.format(sale.discountAmount)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.error)),
              ],
            ),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Akhir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              Text(CurrencyFormatter.format(sale.finalAmount), style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          _buildMetaRow('Tunai Diterima', CurrencyFormatter.format(sale.cashPaid)),
          const SizedBox(height: 8),
          _buildMetaRow('Kembalian', CurrencyFormatter.format(sale.changeAmount)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, WidgetRef ref, bool isVoid) {
    return Row(
      children: [
        if (!isVoid) ...[
          OutlinedButton.icon(
            onPressed: () => _handleVoidSale(context, ref),
            icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
            label: const Text('Void / Batal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final auth = ref.read(authProvider);
              PosReceiptDialog.show(
                context,
                sale: sale,
                storeName: auth.currentStore?.name ?? 'Tokona Store',
                cashierName: auth.currentUser?.fullName,
                storeAddress: auth.currentStore?.address,
                storePhone: auth.currentStore?.phone,
              );
            },
            icon: const Icon(Icons.receipt_outlined, size: 16),
            label: const Text('Cetak / Lihat Struk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ],
    );
  }
}

