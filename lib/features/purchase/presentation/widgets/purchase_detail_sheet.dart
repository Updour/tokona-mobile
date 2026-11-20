import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/edit_purchase_items_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_detail_item_tile.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_financial_summary_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_tracking_section.dart';

class PurchaseDetailSheet extends ConsumerWidget {
  final PurchaseModel purchase;

  const PurchaseDetailSheet({
    super.key,
    required this.purchase,
  });

  static Future<void> show(BuildContext context, PurchaseModel purchase) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseDetailSheet(purchase: purchase),
    );
  }

  Future<void> _handleConfirmArrival(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Konfirmasi Barang Tiba',
      message: 'Paket nota ${purchase.invoiceNumber} sudah tiba? Stok barang otomatis bertambah.',
      confirmText: 'Ya, Terima Barang',
      icon: Icons.inventory_2_outlined,
    );
    if (confirmed == true && context.mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      await ref.read(purchaseRepositoryProvider).confirmReceived(purchase.id);
      if (!context.mounted) return;
      if (sId != null) {
        ref.read(productListProvider.notifier).loadProducts(sId);
        ref.read(purchaseControllerProvider.notifier).loadPurchases(sId);
      }
      AppToast.showSuccess(context, 'Stok barang berhasil ditambahkan');
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleRevertToShipping(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Kembalikan ke Dalam Pengiriman?',
      message: 'Barang faktur ${purchase.invoiceNumber} belum tiba? Status akan dikembalikan ke Dalam Pengiriman dan stok disesuaikan.',
      confirmText: 'Ya, Kembalikan',
      icon: Icons.undo_rounded,
    );
    if (confirmed == true && context.mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) {
        final ok = await ref.read(purchaseControllerProvider.notifier).revertToShipping(purchase.id, sId);
        if (context.mounted) {
          if (ok) {
            AppToast.showSuccess(context, 'Pesanan dikembalikan ke status OTW');
            Navigator.of(context).pop();
          } else {
            AppToast.showError(context, 'Gagal mengembalikan status pesanan');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail Faktur Pembelian', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(purchase.invoiceNumber, style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                  tooltip: 'Edit & Tambah Barang Faktur',
                  onPressed: () => EditPurchaseItemsSheet.show(context, purchase),
                ),
                IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.textMuted), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildHeaderInfoCard(context, ref, dateFormat),
                  const SizedBox(height: 16),
                  _buildItemsSection(context),
                  const SizedBox(height: 16),
                  PurchaseFinancialSummaryCard(purchase: purchase),
                  if (purchase.notes != null && purchase.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                  ],
                  _buildProofPhoto(context),
                ],
              ),
            ),
            if (purchase.isPreOrder || purchase.isShipping) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _handleConfirmArrival(context, ref),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Barang Sudah Diterima', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else if (purchase.isReceived) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _handleRevertToShipping(context, ref),
                icon: const Icon(Icons.undo_rounded, size: 16, color: Color(0xFFD97706)),
                label: const Text('Barang Belum Tiba? Kembalikan ke Dalam Pengiriman', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFDE68A)),
                  backgroundColor: const Color(0xFFFFFBEB),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfoCard(BuildContext context, WidgetRef ref, DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceInput, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _buildInfoRow('Tanggal Pembelian', dateFormat.format(purchase.createdAt)),
          const SizedBox(height: 7),
          _buildInfoRow('No. Faktur', purchase.invoiceNumber),
          const SizedBox(height: 7),
          _buildInfoRow('Nama Supplier', purchase.supplierName ?? 'Tanpa Nama Supplier'),
          const SizedBox(height: 7),
          _buildInfoRow('Saluran Pembelian', purchase.isOnline ? 'Online (${purchase.platform ?? "Marketplace"})' : 'Toko Fisik / Offline'),
          if (purchase.deviceTag != null && purchase.deviceTag!.isNotEmpty) ...[
            const SizedBox(height: 7),
            _buildInfoRow('Device Belanja', '📱 ${purchase.deviceTag!}'),
          ],
          if (purchase.paymentAccount != null && purchase.paymentAccount!.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            _buildInfoRow('Akun Pembayaran', purchase.paymentAccount!),
          ],
          if (purchase.trackingNumber != null && purchase.trackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 7),
            PurchaseTrackingSection(
              rawTracking: purchase.trackingNumber!,
              onConfirmArrival: () => _handleConfirmArrival(context, ref),
            ),
          ],
          if (purchase.estimatedArrival != null) ...[
            const SizedBox(height: 7),
            _buildInfoRow(
              'Estimasi Tiba',
              purchase.estimatedArrivalEnd != null
                  ? '${DateFormat('dd MMM').format(purchase.estimatedArrival!)} – ${DateFormat('dd MMM yyyy').format(purchase.estimatedArrivalEnd!)}'
                  : DateFormat('dd MMM yyyy').format(purchase.estimatedArrival!),
            ),
          ],
          if (purchase.isAutoReceived) ...[
            const SizedBox(height: 7),
            _buildInfoRow('Penerimaan', '🤖 Otomatis by Sistem'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(width: 8),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
        ],
      );

  Widget _buildItemsSection(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rincian Barang (${purchase.items.length})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              InkWell(
                onTap: () => EditPurchaseItemsSheet.show(context, purchase),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 13, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Edit / Tambah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...purchase.items.map((item) => PurchaseDetailItemTile(item: item)),
        ],
      );

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceInput, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catatan Pembelian:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(purchase.notes!, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildProofPhoto(BuildContext context) {
    if (purchase.imagePath == null || purchase.imagePath!.trim().isEmpty) return const SizedBox.shrink();
    final file = File(purchase.imagePath!);
    if (!file.existsSync()) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.photo_camera_back_outlined, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Foto Faktur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
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
            child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(file, height: 160, width: double.infinity, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 6),
          const Text('Ketuk untuk perbesar', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
