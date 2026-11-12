import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';

class EditPurchaseInvoiceDialog {
  EditPurchaseInvoiceDialog._();

  static Future<void> show(BuildContext context, WidgetRef ref, PurchaseModel purchase) async {
    final invController = TextEditingController(text: purchase.invoiceNumber);
    final supplierController = TextEditingController(text: purchase.supplierName ?? '');
    final notesController = TextEditingController(text: purchase.notes ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit No. Faktur & Toko', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: invController, decoration: const InputDecoration(labelText: 'No. Faktur / Nota Toko', hintText: 'Contoh: INV-SHOPEE-991')),
            const SizedBox(height: 10),
            TextField(controller: supplierController, decoration: const InputDecoration(labelText: 'Nama Toko / Distributor', hintText: 'Contoh: Toko Jaya')),
            const SizedBox(height: 10),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Catatan Faktur (Opsional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved == true && context.mounted) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        final success = await ref.read(purchaseControllerProvider.notifier).updatePurchaseInvoiceAndSupplier(
          purchaseId: purchase.id,
          invoiceNumber: invController.text.trim().isEmpty ? purchase.invoiceNumber : invController.text.trim(),
          supplierName: supplierController.text.trim().isEmpty ? null : supplierController.text.trim(),
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          storeId: storeId,
        );
        if (success && context.mounted) {
          AppToast.showSuccess(context, 'Info faktur & nama toko berhasil diperbarui');
          Navigator.of(context).pop();
        }
      }
    }
  }
}
